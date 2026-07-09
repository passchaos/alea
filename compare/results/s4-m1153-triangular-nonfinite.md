# S4-M1153 Triangular Nonfinite Bounds Compatibility

## Gap

S4-M1152 aligned Beta infinite-shape sampling with local `rand_distr 0.6.0`.
A follow-up audit found that local `rand_distr::Triangular::new(min, max, mode)`
validates via comparisons only: NaN values are rejected, but ordered `-inf` /
`+inf` bounds and modes are accepted. Sampling those non-finite bounds evaluates
the Rust triangular transform and produces NaN while consuming the uniform draw.
Alea previously rejected any non-finite triangular parameter in reusable
constructors and would not match the Rust transform for accepted non-finite
bounds.

## Local Rust baseline

Cached `rand_distr 0.6.0` source:

```text
$ sed -n '83,91p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/triangular.rs
pub fn new(min: F, max: F, mode: F) -> Result<Triangular<F>, TriangularError> {
    if !(max >= min) {
        return Err(TriangularError::RangeTooSmall);
    }
    if !(mode >= min && max >= mode) {
        return Err(TriangularError::ModeRange);
    }
    Ok(Triangular { min, max, mode })
}
```

A local cargo probe against the cached crate confirms accepted non-finite ordered
bounds and NaN samples:

```text
max_inf_mode_finite sample=NaN nan=true finite=false inf=false
max_inf_mode_inf sample=NaN nan=true finite=false inf=false
min_neg_inf_mode_finite sample=NaN nan=true finite=false inf=false
min_neg_inf_mode_neg_inf sample=NaN nan=true finite=false inf=false
both_unbounded_mode_0 sample=NaN nan=true finite=false inf=false
both_unbounded_mode_inf sample=NaN nan=true finite=false inf=false
both_unbounded_mode_neg_inf sample=NaN nan=true finite=false inf=false
nan_min_err=true
nan_max_err=true
nan_mode_err=true
```

## Implementation

- Relaxed Triangular validation to accept ordered non-finite bounds/modes while
  still rejecting NaN or unordered ranges through the comparison checks.
- Added a Rust-shaped triangular transform for non-finite parameter paths, so
  accepted non-finite bounds consume the same uniform/vector-uniform draw shape
  and produce NaN rather than Alea's previous finite-only formula artifacts.
- Preserved existing collapsed `min == mode == max` no-consume point-mass
  behavior.
- Focused tests cover scalar/vector checked, unchecked, fill, reusable,
  facade/direct-source paths plus invalid NaN/no-consume cases.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "triangular"
1/3 distributions.test.nonfinite triangular bounds preserve rand_distr-compatible stream shape...OK
2/3 distributions.test.degenerate triangular helpers do not consume random stream...OK
3/3 root.test_0...OK
All 3 tests passed.

$ zig test src/distributions.zig --test-filter "distribution vector helpers"
1/3 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/3 distributions.test.invalid distribution vector helpers do not consume random stream...OK
3/3 root.test_0...OK
All 3 tests passed.

$ zig test src/distributions.zig --test-filter "non-uniform samplers"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.
```

## Full validation

The final S4-M1153 validation run also passed:

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
rand_distr standard-normal: 36.2 M samples/s checksum=-3.640
rand_distr standard-normal f32: 39.1 M samples/s checksum=-3.640
$ zig build test
# passed
```

## Result

S4-M1153 is closed for the current bar: Alea now accepts local `rand_distr`
Triangular non-finite ordered bounds and preserves the corresponding NaN output
and uniform draw-shape behavior. This is not whole-goal completion; S4-M1154
remains active.
