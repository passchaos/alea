# S4-M1154 PERT Infinite-Shape Compatibility

## Gap

S4-M1153 aligned Triangular non-finite bounds with local `rand_distr 0.6.0`.
A follow-up audit found that local `rand_distr::Pert::new(min, max).with_shape(inf).with_mode(mode)`
accepts finite non-collapsed ranges only when `mode` is strictly inside the
range. Sampling that edge constructs Beta parameters `(inf, inf)`, consumes the
Beta infinite-parameter Cheng draw shape, and produces NaN. Alea previously
accepted `shape == +inf` as a deterministic mode point mass without consuming
randomness, including builder paths.

Alea keeps its existing collapsed-range PERT point-mass extension, even though
local `rand_distr` rejects collapsed ranges. This S4-M1154 closure only changes
finite-range `shape == +inf` behavior to match local Rust.

## Local Rust baseline

Cached `rand_distr 0.6.0` source:

```text
$ sed -n '139,159p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/pert.rs
pub fn with_mode(self, mode: F) -> Result<Pert<F>, PertError> {
    if !(self.max > self.min) {
        return Err(PertError::RangeTooSmall);
    }
    if !(mode >= self.min && self.max >= mode) {
        return Err(PertError::ModeRange);
    }
    if !(self.shape >= F::from(0.).unwrap()) {
        return Err(PertError::ShapeTooSmall);
    }

    let (min, max, shape) = (self.min, self.max, self.shape);
    let range = max - min;
    let v = F::from(1.0).unwrap() + shape * (mode - min) / range;
    let w = F::from(1.0).unwrap() + shape * (max - mode) / range;
    let beta = Beta::new(v, w).map_err(|_| PertError::RangeTooSmall)?;
```

A local cargo probe against the cached crate confirms the edge behavior:

```text
shape_inf_mode_mid sample=NaN nan=true finite=false inf=false
shape_inf_mode_min err=RangeTooSmall
shape_inf_mode_max err=RangeTooSmall
shape_inf_mean_mid err=ModeRange
shape_inf_mean_min err=ModeRange
shape_inf_mean_max err=ModeRange
shape_zero_mode_mid sample=1.6131326787977291 nan=false finite=true inf=false
collapsed_shape_inf err=RangeTooSmall
```

## Implementation

- Finite-range PERT with `shape == +inf` now derives `(alpha, beta) = (inf,
  inf)` and routes through the Beta infinite-parameter path, producing NaN while
  preserving Beta's draw shape.
- `shape == +inf` with mode at either endpoint is now invalid for finite ranges,
  matching local `rand_distr`'s Beta-construction failure.
- `initMean(..., shape=+inf)` for finite ranges now remains invalid because the
  derived mode is not a valid local `rand_distr` builder mode.
- Existing Alea collapsed-range point-mass behavior remains no-consume and is
  documented as a parity-plus extension.
- Focused tests cover scalar/vector checked, unchecked, fill, reusable, builder,
  direct-source, invalid endpoint/mean, and collapsed no-consume paths.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "pert"
1/4 distributions.test.collapsed pert helpers do not consume random stream...OK
2/4 distributions.test.infinite-shape pert helpers preserve rand_distr-compatible stream shape...OK
3/4 distributions.test.zero-length skew and pert fills do not validate or consume random stream...OK
4/4 root.test_0...OK
All 4 tests passed.

$ zig test src/distributions.zig --test-filter "non-uniform samplers"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.
```

## Full validation

The final S4-M1154 validation run also passed:

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
$ zig build validate-local
# passed; smoke output included:
rand_distr standard-normal: 41.9 M samples/s checksum=-3.640
rand_distr standard-normal f32: 38.9 M samples/s checksum=-3.640
$ zig build test
# passed
```

## Result

S4-M1154 is closed for the current bar: Alea finite-range PERT `shape == +inf`
now matches local `rand_distr` by preserving Beta infinite-parameter NaN output
and draw shape, while collapsed-range PERT remains an Alea extension. This is
not whole-goal completion; S4-M1155 remains active.
