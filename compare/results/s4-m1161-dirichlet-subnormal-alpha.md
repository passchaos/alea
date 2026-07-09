# S4-M1161 Dirichlet Subnormal-Alpha Compatibility

## Gap

S4-M1160 aligned Hypergeometric large-population HIN underflow handling with
local `rand_distr 0.6.0`. A follow-up multivariate audit found that local
`rand_distr::multi::Dirichlet::new(alpha)` rejects positive subnormal alpha
values with `AlphaSubnormal`.

Alea's `Dirichlet(T)` already had Zig-native deterministic extensions for
one-dimensional simplexes and exactly one infinite alpha. However, it accepted
finite positive subnormal alpha values and could then route them into Gamma
sampling. S4-M1161 aligns the finite-subnormal constructor edge while preserving
those documented Alea extensions.

## Local Rust baseline

Cached `rand_distr 0.6.0` source:

```text
$ sed -n '288,307p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/multi/dirichlet.rs
    pub fn new(alpha: &[F]) -> Result<Dirichlet<F>, Error> {
        if alpha.len() < 2 {
            return Err(Error::AlphaTooShort);
        }
        for &ai in alpha.iter() {
            if !(ai > F::zero()) {
                // This also catches nan.
                return Err(Error::AlphaTooSmall);
            }
            if ai.is_infinite() {
                return Err(Error::AlphaInfinite);
            }
            if !ai.is_normal() {
                return Err(Error::AlphaSubnormal);
            }
        }
```

A focused local cargo probe confirms constructor edges:

```text
empty: err AlphaTooShort
one: err AlphaTooShort
zero: err AlphaTooSmall
neg: err AlphaTooSmall
nan: err AlphaTooSmall
inf: err AlphaInfinite
two-inf: err AlphaInfinite
min-positive: ok
subnormal: err AlphaSubnormal
subnormal2: err AlphaSubnormal
tiny-normal: ok
small-normal: ok
ok: ok
```

## Implementation

- `Dirichlet(T).init` now rejects finite positive subnormal alpha values with
  Alea's shared `error.InvalidParameter`.
- `multi.Dirichlet(T)` inherits the same validation because it aliases
  `Dirichlet(T)`.
- Normal positive `std.math.floatMin(T)` values remain accepted, matching local
  `rand_distr`'s `is_normal` predicate.
- Alea's documented extensions remain intact: one-dimensional simplexes are
  deterministic point masses, and exactly one infinite alpha remains a
  deterministic vertex point mass.
- Focused tests cover scalar and namespace-alias rejection, normal-minimum
  acceptance, and both deterministic extensions.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "dirichlet"
1/3 distributions.test.dirichlet sampler returns simplex vectors...OK
2/3 distributions.test.dirichlet subnormal alpha rejection matches local rand_distr...OK
3/3 root.test_0...OK
All 3 tests passed.
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
- Current conclusion: S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1161 follow-ups closed for current bar
- Next bar: S4-M1162 post-S4-M1161 exact/default dense SIMD, broader runtime, or new local Rust gap
$ zig build rand-status-json
  "latest_validate_local_evidence": "compare/results/s4-m1161-dirichlet-subnormal-alpha.md"
$ zig build rand-status-schema-version
1
$ zig build rand-status-self-test
rand-status self-test ok
$ zig build validate-local
rand_distr standard-normal: 61.3 M samples/s checksum=-3.640
rand_distr standard-normal f32: 59.0 M samples/s checksum=-3.640
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

S4-M1161 is closed for the current bar: Dirichlet finite positive subnormal
alpha values now reject like local `rand_distr::multi::Dirichlet`, while Alea's
one-dimensional and single-infinite-alpha deterministic extensions remain
available and documented. This is not whole-goal completion; S4-M1162 remains
active.
