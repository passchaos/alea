# S4-M1159 NormalInverseGaussian Alpha-Infinity Compatibility

## Gap

S4-M1158 aligned `SkewNormal` unrestricted-location semantics with local
`rand_distr 0.6.0`. A follow-up inverse-Gaussian-family audit found that local
`rand_distr::NormalInverseGaussian::new(alpha, beta)` rejects
`alpha == +inf` with `AlphaInfinite`: the constructor derives
`gamma = alpha * sqrt(1 - (beta / alpha)^2)`, computes `mu = 1 / gamma`, and
then maps the embedded `InverseGaussian::new(mu, 1)` zero-mean rejection to
`AlphaInfinite`.

Alea previously accepted finite beta with `alpha == +inf` as a no-consume zero
point-mass extension. S4-M1159 removes that extension and aligns the checked and
reusable constructor surfaces with local `rand_distr`.

## Local Rust baseline

Cached `rand_distr 0.6.0` source:

```text
$ sed -n '79,97p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/normal_inverse_gaussian.rs
    pub fn new(alpha: F, beta: F) -> Result<NormalInverseGaussian<F>, Error> {
        if !(alpha > F::zero()) {
            return Err(Error::AlphaNegativeOrNull);
        }

        if !(beta.abs() < alpha) {
            return Err(Error::AbsoluteBetaNotLessThanAlpha);
        }
        // Note: this calculation method for gamma = sqrt(alpha * alpha - beta * beta)
        // avoids overflow if alpha is large, ensuring gamma <= alpha, which implies
        // (assuming IEEE754 with subnormals) mu = 1.0 / gamma >= 1 / F::max_value() > 0.
        let r = beta / alpha;
        let gamma = alpha * (F::one() - r * r).sqrt();
        let mu = F::one() / gamma;
        let inverse_gaussian = InverseGaussian::new(mu, F::one()).map_err(|x| match x {
            InverseGaussianError::MeanNegativeOrNull => Error::AlphaInfinite,
```

A local cargo probe confirms constructor edges:

```text
alpha=inf beta=0.0 err=AlphaInfinite
alpha=inf beta=1.0 err=AlphaInfinite
alpha=inf beta=inf err=AbsoluteBetaNotLessThanAlpha
alpha=1.7976931348623157e308 beta=0.0 ok sample_class=finite
alpha=1.7976931348623157e308 beta=8.988465674311579e307 ok sample_class=finite
alpha=3.0 beta=inf err=AbsoluteBetaNotLessThanAlpha
alpha=3.0 beta=NaN err=AbsoluteBetaNotLessThanAlpha
alpha=NaN beta=0.0 err=AlphaNegativeOrNull
alpha=3.0 beta=1.0 ok sample_class=finite
```

## Implementation

- `NormalInverseGaussian(T).init` and `VectorNormalInverseGaussian` now reject
  `alpha == +inf`, NaN alpha, non-finite beta, and `abs(beta) >= alpha`, matching
  local constructor acceptance with Alea's shared `error.InvalidParameter`.
- Top-level checked scalar/vector sample and fill helpers now reject
  `alpha == +inf` without consuming randomness.
- Unchecked helper assertions now require finite alpha and no longer provide an
  `alpha == +inf` point-mass path.
- `alphaValue` and `varianceValue` use overflow-resistant derived formulas so
  very large finite-alpha samplers remain constructible and diagnostically safe.
- Focused tests cover scalar/vector checked and reusable rejection, invalid
  no-consume behavior, and continued acceptance of very large finite alpha.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "normal-inverse-gaussian"
1/2 distributions.test.normal-inverse-gaussian infinity rejection matches local rand_distr...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.
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
- Current conclusion: S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1159 follow-ups closed for current bar
- Next bar: S4-M1160 post-S4-M1159 exact/default dense SIMD, broader runtime, or new local Rust gap
$ zig build rand-status-json
  "latest_validate_local_evidence": "compare/results/s4-m1159-nig-alpha-infinity.md"
$ zig build rand-status-schema-version
1
$ zig build rand-status-self-test
rand-status self-test ok
$ zig build validate-local
rand_distr standard-normal: 39.8 M samples/s checksum=-3.640
rand_distr standard-normal f32: 37.2 M samples/s checksum=-3.640
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

S4-M1159 is closed for the current bar: NormalInverseGaussian now rejects
alpha-infinity like local `rand_distr`, while retaining finite-parameter sampling
and large finite-alpha construction. This is not whole-goal completion;
S4-M1160 remains active.
