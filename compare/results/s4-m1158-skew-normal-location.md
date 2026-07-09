# S4-M1158 SkewNormal Unrestricted-Location Compatibility

## Gap

S4-M1157 aligned InverseGaussian infinite-parameter sampling with local
`rand_distr 0.6.0`. A follow-up tail-distribution audit found that local
`rand_distr::SkewNormal::new(location, scale, shape)` documents `location` as
unrestricted and only requires finite positive scale plus finite shape. Alea
previously rejected non-finite locations even though local `rand_distr` accepts
`+inf`, `-inf`, and `NaN` locations and then propagates those values through the
ordinary sampling transform.

Alea keeps its existing `scale == 0` no-consume point-mass extension even though
local `rand_distr` rejects zero scale; S4-M1158 only aligns the missing
unrestricted-location constructor/sample behavior for nonzero scale.

## Local Rust baseline

Cached `rand_distr 0.6.0` source:

```text
$ sed -n '100,114p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/skew_normal.rs
    /// Parameters:
    ///
    /// -   location (unrestricted)
    /// -   scale (must be finite and larger than zero)
    /// -   shape (must be finite)
    #[inline]
    pub fn new(location: F, scale: F, shape: F) -> Result<SkewNormal<F>, Error> {
        if !scale.is_finite() || !(scale > F::zero()) {
            return Err(Error::ScaleTooSmall);
        }
        if !shape.is_finite() {
            return Err(Error::BadShape);
        }
```

A local cargo probe confirms constructor/sample classes for the audited edges:

```text
location=inf scale=1.0 shape=0.0 ok sample_class=+inf
location=inf scale=1.0 shape=2.0 ok sample_class=+inf
location=-inf scale=1.0 shape=0.0 ok sample_class=-inf
location=-inf scale=1.0 shape=2.0 ok sample_class=-inf
location=NaN scale=1.0 shape=0.0 ok sample_class=nan
location=NaN scale=1.0 shape=2.0 ok sample_class=nan
location=0.0 scale=1.0 shape=0.0 ok sample_class=finite
location=0.0 scale=1.0 shape=2.0 ok sample_class=finite
location=0.0 scale=0.0 shape=1.0 err=ScaleTooSmall
location=0.0 scale=inf shape=1.0 err=ScaleTooSmall
location=0.0 scale=1.0 shape=inf err=BadShape
```

## Implementation

- Removed the finite-location guard from scalar/vector reusable `SkewNormal`
  constructors and from unchecked helper assertions.
- Scalar/vector checked, unchecked, reusable, and fill helpers now accept
  unrestricted locations and preserve the same normal draw shape used for finite
  locations.
- Non-finite locations propagate through samples/fills as local `rand_distr`
  does: `+inf` stays `+inf`, `-inf` stays `-inf`, and `NaN` stays `NaN`.
- Existing Alea `scale == 0` point-mass behavior remains a documented
  parity-plus extension.
- Focused tests cover scalar/vector checked, unchecked, reusable, fill,
  direct-source, accessors, NaN/±inf propagation, draw-shape consumption, and
  continued scale/shape rejection.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "skew-normal unrestricted"
1/2 distributions.test.skew-normal unrestricted location matches local rand_distr...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "skew-normal"
1/3 distributions.test.skew-normal unrestricted location matches local rand_distr...OK
2/3 distributions.test.degenerate skew-normal helpers do not consume random stream...OK
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
- Current conclusion: S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1158 follow-ups closed for current bar
- Next bar: S4-M1159 post-S4-M1158 exact/default dense SIMD, broader runtime, or new local Rust gap
$ zig build rand-status-json
  "latest_validate_local_evidence": "compare/results/s4-m1158-skew-normal-location.md"
$ zig build rand-status-schema-version
1
$ zig build rand-status-self-test
rand-status self-test ok
$ zig build validate-local
rand_distr standard-normal: 33.6 M samples/s checksum=-3.640
rand_distr standard-normal f32: 34.8 M samples/s checksum=-3.640
runtimecheck ok: no additional runtime runner available
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
rand_bench_smoke self-test ok
distcheck ok
statcheck ok
profilecheck ok
roadmapcheck ok
toolingcheck ok
apicheck ok
readmecheck ok
examplecheck ok
$ zig build test
roadmapcheck ok
apicheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M1158 is closed for the current bar: SkewNormal now accepts unrestricted
locations like local `rand_distr`, while retaining Alea's zero-scale point-mass
extension. This is not whole-goal completion; S4-M1159 remains active.
