# S4-M1151 Pareto/Weibull Infinite-Scale Compatibility

## Gap

S4-M1150 aligned Cauchy non-finite parameter acceptance with local
`rand_distr 0.6.0`. A follow-up audit found that local `rand_distr::Pareto::new`
and `rand_distr::Weibull::new` validate parameters with `scale > 0` and
`shape > 0`; they accept `scale = +inf` and `shape = +inf`. Alea already
accepted infinite shape as a deterministic point-mass extension for both
families, but it rejected infinite scale.

## Local Rust baseline

Cached `rand_distr 0.6.0` source:

```text
$ sed -n '79,90p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/pareto.rs
pub fn new(scale: F, shape: F) -> Result<Pareto<F>, Error> {
    let zero = F::zero();

    if !(scale > zero) {
        return Err(Error::ScaleTooSmall);
    }
    if !(shape > zero) {
        return Err(Error::ShapeTooSmall);
    }
```

```text
$ sed -n '83,92p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/weibull.rs
pub fn new(scale: F, shape: F) -> Result<Weibull<F>, Error> {
    if !(scale > F::zero()) {
        return Err(Error::ScaleTooSmall);
    }
    if !(shape > F::zero()) {
        return Err(Error::ShapeTooSmall);
    }
```

A local cargo probe against the cached crate confirms accepted infinite scale
and shape edges and rejected zero/NaN edges:

```text
pareto_scale_inf sample=inf nan=false finite=false inf=true
pareto_shape_inf sample=2.0 nan=false finite=true inf=false
pareto_both_inf sample=inf nan=false finite=false inf=true
pareto_zero_scale_err=true
pareto_nan_scale_err=true
pareto_nan_shape_err=true
weibull_scale_inf sample=inf nan=false finite=false inf=true
weibull_shape_inf sample=2.0 nan=false finite=true inf=false
weibull_both_inf sample=inf nan=false finite=false inf=true
weibull_zero_scale_err=true
weibull_nan_scale_err=true
weibull_nan_shape_err=true
```

## Implementation

- Relaxed Pareto and Weibull validation to accept `scale == +inf` while
  continuing to reject negative and NaN scale values.
- Preserved existing Alea parity-plus `scale == 0` and `shape == +inf`
  deterministic point-mass extensions; local `rand_distr` rejects zero scale but
  accepts infinite shape and samples the scale value.
- Finite-shape `scale == +inf` paths now preserve the transform draw shape: they
  consume the same open-uniform/standard-exponential style source draws as finite
  scale paths and produce `+inf`.
- Focused tests cover scalar/vector checked, unchecked, fill, reusable,
  facade/direct-source paths plus invalid scale no-consume cases for Pareto and
  Weibull.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "infinite-scale"
1/2 distributions.test.infinite-scale pareto and weibull helpers preserve transform stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "pareto"
1/3 distributions.test.degenerate pareto helpers do not consume random stream...OK
2/3 distributions.test.infinite-scale pareto and weibull helpers preserve transform stream shape...OK
3/3 root.test_0...OK
All 3 tests passed.

$ zig test src/distributions.zig --test-filter "weibull"
1/3 distributions.test.infinite-scale pareto and weibull helpers preserve transform stream shape...OK
2/3 distributions.test.degenerate weibull helpers do not consume random stream...OK
3/3 root.test_0...OK
All 3 tests passed.
```

## Full validation

The final S4-M1151 validation run also passed:

```text
$ git diff --check
$ zig build roadmapcheck
roadmapcheck ok
$ zig build toolingcheck
toolingcheck ok
$ zig build rand-status
$ zig build rand-status-json
$ zig build rand-status-schema-version
1
$ zig build rand-status-self-test
rand-status self-test ok
$ zig test src/distributions.zig --test-filter "non-uniform samplers"
# passed
$ zig build validate-local
# passed; smoke output included:
rand_distr standard-normal: 41.7 M samples/s checksum=-3.640
rand_distr standard-normal f32: 37.6 M samples/s checksum=-3.640
$ zig build test
# passed
```

## Result

S4-M1151 is closed for the current bar: Alea now accepts local `rand_distr`
Pareto/Weibull infinite-scale parameter edges while preserving finite-path draw
shape and the existing Alea point-mass extensions. This is not whole-goal
completion; S4-M1152 remains active.
