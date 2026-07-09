# S4-M1146 Mean/CV Edge Compatibility

## Gap

S4-M1145 aligned `Normal::new(mean, std_dev)` and `LogNormal::new(mu, sigma)`
with local `rand_distr 0.6.0` by treating normal/log-space means as
unrestricted while still rejecting non-finite explicit standard deviations. A
follow-up audit found one remaining constructor-family edge: local
`Normal::from_mean_cv(mean, cv)` does not call `Normal::new`; it only validates
`cv` and stores `std_dev = cv * mean`, so unrestricted means can produce
non-finite stored standard deviations. Local `LogNormal::from_mean_cv(mean, 0)`
also returns `Normal::new(mean.ln(), 0)` before enforcing positive mean, and its
positive finite-CV branch accepts `mean == +inf` until a non-finite derived sigma
would be rejected by `Normal::new`.

Alea still routed `Normal(T).initMeanCv` through `Normal(T).init`, and
`LogNormal(T).initMeanCv` rejected non-positive or non-finite means before the
zero-CV branch. That left a narrow local `rand_distr::from_mean_cv` edge gap.

## Local Rust baseline

Cached `rand_distr 0.6.0` source:

```text
$ sed -n '203,208p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/normal.rs
pub fn from_mean_cv(mean: F, cv: F) -> Result<Normal<F>, Error> {
    if !cv.is_finite() || cv < F::zero() {
        return Err(Error::BadVariance);
    }
    let std_dev = cv * mean;
    Ok(Normal { mean, std_dev })
```

```text
$ sed -n '311,334p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/normal.rs
pub fn from_mean_cv(mean: F, cv: F) -> Result<LogNormal<F>, Error> {
    if cv == F::zero() {
        let mu = mean.ln();
        let norm = Normal::new(mu, F::zero()).unwrap();
        return Ok(LogNormal { norm });
    }
    if !(mean > F::zero()) {
        return Err(Error::MeanTooSmall);
    }
    if !(cv >= F::zero()) {
        return Err(Error::BadVariance);
    }
    ...
    let sigma = a.ln().sqrt();
    let norm = Normal::new(mu, sigma)?;
    Ok(LogNormal { norm })
}
```

A local cargo probe against the cached crate confirms the edge behavior:

```text
normal_inf_zero mean=inf std_nan=true
normal_nan mean_nan=true std_nan=true
normal_cv_inf_err=true
lognormal_neg_zero=LogNormal { norm: Normal { mean: NaN, std_dev: 0.0 } }
lognormal_inf=LogNormal { norm: Normal { mean: inf, std_dev: 0.47238072707743883 } }
lognormal_cv_inf_err=true
```

## Implementation

- `Normal(T).initMeanCv` / `fromMeanCv` now validate only finite non-negative
  CV and then store `stddev = mean * cv` directly, matching local
  `rand_distr::Normal::from_mean_cv` even when the product is non-finite.
- Reusable exact `Normal(T)` sample/fill methods now support these internally
  non-finite mean-CV states by consuming standard-normal draws and applying the
  same affine transform, while explicit `Normal(T).init(mean, stddev)` still
  rejects non-finite `stddev`.
- `LogNormal(T).initMeanCv` now matches the local branch ordering: zero CV
  stores `log(mean)` with zero log-stddev before positive-mean validation, while
  positive CV accepts `mean == +inf` and still rejects invalid/non-finite derived
  sigma through `Normal(T).init`.
- Focused tests cover non-finite `Normal.fromMeanCv` states, zero-CV negative
  `LogNormal.fromMeanCv`, positive-CV infinite-mean `LogNormal.fromMeanCv`, and
  invalid infinite-CV cases.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "normal"
1/24 distributions.test.invalid normal exponential wrapper helpers do not consume random stream...OK
2/24 distributions.test.degenerate normal and log-normal helpers do not consume random stream...OK
...
24/24 quality.test.normal and exponential means stay in broad windows...OK
All 24 tests passed.
```

Full local aggregate after updating the latest-evidence pointer:

```text
$ zig build validate-local
...
rand_distr standard-normal: 41.0 M samples/s checksum=-3.640
rand_distr standard-normal f32: 39.6 M samples/s checksum=-3.640
rand-status self-test ok
roadmapcheck ok
toolingcheck ok
runtimecheck ok: no additional runtime runner available
apicheck ok
surfacecheck ok
examplecheck ok
readmecheck ok
statcheck ok
distcheck ok
practrand self-test ok
profilecheck ok
```

Broad package tests also pass:

```text
$ zig build test
apicheck ok
examplecheck ok
```

## Result

S4-M1146 is closed for the current bar: Alea now matches the local
`rand_distr::from_mean_cv` edge semantics for exact reusable Normal and
LogNormal constructors while preserving the explicit-constructor finite-stddev
contract. This is not whole-goal completion; S4-M1147 remains active.
