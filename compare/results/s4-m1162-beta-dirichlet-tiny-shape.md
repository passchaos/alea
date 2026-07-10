# S4-M1162 Beta and Dirichlet Tiny-Shape Stability

## Gap

S4-M1161 aligned `Dirichlet(T)` constructor validation with local
`rand_distr::multi::Dirichlet::new` for positive subnormal alpha values. A
follow-up sampling audit found a remaining finite tiny-shape behavior gap:
Alea's generic `Beta(T)` used a Gamma-ratio implementation, and all-small
`Dirichlet(T)` therefore could normalize `0 / (0 + 0)` when both Gamma draws
underflowed. Local `rand_distr` uses Cheng's Beta BB/BC sampler for `Beta` and
uses a Beta stick-breaking representation for `Dirichlet` when all alpha values
are `<= 0.1`; those local Rust paths return endpoint or finite simplex values
instead of NaN for tiny normal shapes.

## Local Rust baseline

Cached `rand_distr 0.6.0` `Beta::new` source uses Cheng BB/BC directly:

```text
$ sed -n '121,175p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/beta.rs
    pub fn new(alpha: F, beta: F) -> Result<Beta<F>, Error> {
        if !(alpha > F::zero()) {
            return Err(Error::AlphaTooSmall);
        }
        if !(beta > F::zero()) {
            return Err(Error::BetaTooSmall);
        }
        // From now on, we use the notation from the reference,
        // i.e. `alpha` and `beta` are renamed to `a0` and `b0`.
        let (a0, b0) = (alpha, beta);
        let (a, b, switched_params) = if a0 < b0 {
            (a0, b0, false)
        } else {
            (b0, a0, true)
        };
        if a > F::one() {
            // Algorithm BB
...
        } else {
            // Algorithm BC
...
```

Cached `rand_distr 0.6.0` `Dirichlet::new` chooses Beta stick-breaking for
all-small alpha vectors:

```text
$ sed -n '309,319p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/multi/dirichlet.rs
        if alpha.iter().all(|&x| x <= NumCast::from(0.1).unwrap()) {
            // Use the Beta method when all the alphas are less than 0.1  This
            // threshold provides a reasonable compromise between using the faster
            // Gamma method for as wide a range as possible while ensuring that
            // the probability of generating nans is negligibly small.
            let dist = DirichletFromBeta::new(alpha).map_err(|_| Error::FailedToCreateBeta)?;
```

Focused local probes confirmed the behavioral split:

```text
# local rand_distr::Beta
Beta(1e-200, 1e-200) ok sample class=zero-or-one
Beta(1e-100, 1e-100) ok sample class=zero-or-one
Beta(1e-10, 1e-10) ok sample class=zero-or-one
Beta(0.01, 0.05) ok sample class=finite

# local rand_distr::multi::Dirichlet
Dirichlet([f64::MIN_POSITIVE, f64::MIN_POSITIVE]) sample classes=[zero-or-one, zero-or-one], sum=1
Dirichlet([1e-200, 1e-200]) sample classes=[zero-or-one, zero-or-one], sum=1
Dirichlet([1e-10, 1e-10]) sample classes=[zero-or-one, zero-or-one], sum=1
Dirichlet([0.01, 0.02, 0.03]) sample classes=finite-or-endpoint, sum=1
```

Before S4-M1162, equivalent Alea probes could produce `NaN` for
`Beta(1e-10, 1e-10)` and `Dirichlet([1e-10, 1e-10])` because the generic
Gamma-ratio path could underflow both Gamma draws to zero.

## Implementation

- Shared finite/infinite Cheng sampling was consolidated as `betaChengFrom`.
- Finite `Beta(T)` top-level, checked, reusable, scalar fill, vector, and vector
  fill paths now route very small shapes through Cheng sampling when either
  shape is `<= 0.1`, avoiding Gamma-ratio `0/0` NaN while preserving the
  existing faster Gamma-backed path for ordinary shapes such as `Beta(2,5)`.
- `Dirichlet(T).sampleInto*` now uses Beta stick-breaking when all finite alpha
  values are `<= 0.1`, matching local `rand_distr::multi::Dirichlet`'s stability
  branch and preserving valid simplex sums for tiny normal alphas.
- Existing special cases (`Beta(1,1)`, `Beta(2,1)`, `Beta(1,2)`, one-sided
  `beta_param == 1`, infinite-shape Beta, one-dimensional Dirichlet, and
  single-infinite-alpha Dirichlet) remain intact.
- Focused tests cover tiny-shape Beta scalar/reusable/fill/vector outputs and
  tiny-shape Dirichlet single/batch outputs, verifying no NaN and simplex sums.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "beta"
1/4 distributions.test.infinite beta helpers preserve rand_distr-compatible stream shape...OK
2/4 distributions.test.tiny-shape beta helpers avoid gamma-ratio NaN like local rand_distr...OK
3/4 distributions.test.tiny-shape dirichlet beta stick-breaking avoids gamma-ratio NaN like local rand_distr...OK
4/4 root.test_0...OK
All 4 tests passed.

$ zig test src/distributions.zig --test-filter "dirichlet"
1/4 distributions.test.dirichlet sampler returns simplex vectors...OK
2/4 distributions.test.dirichlet subnormal alpha rejection matches local rand_distr...OK
3/4 distributions.test.tiny-shape dirichlet beta stick-breaking avoids gamma-ratio NaN like local rand_distr...OK
4/4 root.test_0...OK
All 4 tests passed.
```

## Full validation

```text
$ git diff --check
$ zig build roadmapcheck
roadmapcheck ok
$ zig build toolingcheck
toolingcheck ok
$ zig build rand-status
Alea local rand/rand_distr status (2026-07-10)
- Current conclusion: S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1162 follow-ups closed for current bar
- Next bar: S4-M1163 post-S4-M1162 exact/default dense SIMD, broader runtime, or new local Rust gap
$ zig build rand-status-json
  "latest_validate_local_evidence": "compare/results/s4-m1162-beta-dirichlet-tiny-shape.md"
$ zig build rand-status-schema-version
1
$ zig build rand-status-self-test
rand-status self-test ok
$ zig build validate-local
rand_distr standard-normal: 41.0 M samples/s checksum=-3.640
rand_distr standard-normal f32: 37.9 M samples/s checksum=-3.640
runtimecheck ok: no additional runtime runner available
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
rand_bench_smoke self-test ok
distcheck ok
statcheck ok
roadmapcheck ok
toolingcheck ok
apicheck ok
readmecheck ok
examplecheck ok
$ zig build test
apicheck ok
roadmapcheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M1162 is closed for the current bar: tiny normal Beta shapes and all-small
Dirichlet concentration vectors now avoid Gamma-ratio NaN and produce local
`rand_distr`-style endpoint/finite simplex outputs. This is not whole-goal
completion; S4-M1163 remains active.
