# S4-M1155 Poisson Max-Lambda Compatibility

## Gap

S4-M1154 aligned finite-range PERT `shape == +inf` behavior with local
`rand_distr 0.6.0`. A follow-up discrete-distribution audit found that local
`rand_distr::Poisson::new(lambda)` rejects finite positive `lambda` values above
`Poisson::MAX_LAMBDA = 1.844e19`, while Alea only rejected non-finite or
negative lambda values.

Alea keeps its existing `lambda == 0` no-consume point-mass extension even though
local `rand_distr` rejects `lambda <= 0`; S4-M1155 only adds the missing upper
bound guard.

## Local Rust baseline

Cached `rand_distr 0.6.0` source:

```text
$ sed -n '155,170p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/poisson.rs
pub fn new(lambda: F) -> Result<Poisson<F>, Error> {
    if !lambda.is_finite() {
        return Err(Error::NonFinite);
    }
    if !(lambda > F::zero()) {
        return Err(Error::ShapeTooSmall);
    }

    // Use the Knuth method only for low expected values
    let method = if lambda < F::from(12.0).unwrap() {
        Method::Knuth(KnuthMethod::new(lambda))
    } else {
        if lambda > F::from(Self::MAX_LAMBDA).unwrap() {
            return Err(Error::ShapeTooLarge);
```

```text
$ grep -n "MAX_LAMBDA" ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/poisson.rs
185:    pub const MAX_LAMBDA: f64 = 1.844e19;
```

A local cargo probe confirms relevant constructor edges:

```text
lambda=0.0 err=ShapeTooSmall
lambda=-0.0 err=ShapeTooSmall
lambda=inf err=NonFinite
lambda=NaN err=NonFinite
lambda=1.0 ok
lambda=12.0 ok
lambda=1.844e19 ok
lambda=1.845e19 err=ShapeTooLarge
```

## Implementation

- Added Alea's `poissonMaxLambda = 1.844e19` guard to reusable scalar/vector
  Poisson constructors and checked helpers.
- Unchecked/assert-fast Poisson helpers now assert the same finite upper bound.
- Existing Alea `lambda == 0` point-mass extension remains accepted and
  no-consume; this is documented as a parity-plus deviation from local Rust.
- Focused tests cover scalar/vector checked, reusable, fill, and invalid
  no-consume paths for too-large lambda, and verify the exact max value remains
  accepted.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "poisson max"
1/2 distributions.test.poisson max lambda guard matches local rand_distr...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "poisson"
1/4 distributions.test.poisson max lambda guard matches local rand_distr...OK
2/4 distributions.test.invalid poisson ahrens-dieter helper does not consume random stream...OK
3/4 distributions.test.poisson large lambda has plausible moments...OK
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
- Current conclusion: S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1155 follow-ups closed for current bar
- Next bar: S4-M1156 post-S4-M1155 exact/default dense SIMD, broader runtime, or new local Rust gap
$ zig build rand-status-json
  "latest_validate_local_evidence": "compare/results/s4-m1155-poisson-max-lambda.md"
$ zig build rand-status-schema-version
1
$ zig build rand-status-self-test
rand-status self-test ok
$ zig build validate-local
rand_distr standard-normal: 40.8 M samples/s checksum=-3.640
rand_distr standard-normal f32: 37.9 M samples/s checksum=-3.640
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
runtimecheck ok: no additional runtime runner available
distcheck ok
statcheck ok
apicheck ok
profilecheck ok
roadmapcheck ok
toolingcheck ok
$ zig build test
roadmapcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M1155 is closed for the current bar: Alea now rejects too-large finite Poisson
lambda values like local `rand_distr`, while preserving its zero-lambda
point-mass extension. This is not whole-goal completion; S4-M1156 remains active.
