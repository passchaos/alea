# S4-M1157 InverseGaussian Infinity Compatibility

## Gap

S4-M1156 aligned the rand-style failure-count Geometric zero-probability edge
with local `rand_distr 0.6.0`. A follow-up advanced-continuous audit found that
local `rand_distr::InverseGaussian::new(mean, shape)` accepts positive infinite
`mean` and/or `shape` because its constructor only rejects parameters that are
not greater than zero. Sampling those infinite-parameter states still consumes
the StandardNormal plus uniform draw shape and returns `NaN`.

Alea previously treated `shape == +inf` with finite mean as a deterministic
no-consume point-mass extension. S4-M1157 replaces that finite-mean
infinite-shape behavior with local `rand_distr`-compatible NaN output and draw
shape, while preserving Alea's existing `mean == 0` boundary point-mass
extension.

## Local Rust baseline

Cached `rand_distr 0.6.0` source:

```text
$ sed -n '70,80p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/inverse_gaussian.rs
    pub fn new(mean: F, shape: F) -> Result<InverseGaussian<F>, Error> {
        let zero = F::zero();
        if !(mean > zero) {
            return Err(Error::MeanNegativeOrNull);
        }

        if !(shape > zero) {
            return Err(Error::ShapeNegativeOrNull);
        }
```

```text
$ sed -n '91,107p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/inverse_gaussian.rs
        let v: F = rng.sample(StandardNormal);
        let y = mu * v * v;

        let mu_2l = mu / (F::from(2.).unwrap() * l);

        let x = mu + mu_2l * (y - (F::from(4.).unwrap() * l * y + y * y).sqrt());

        let u: F = rng.random();

        if u <= mu / (mu + x) {
            return x;
        }
```

A local cargo probe with a deterministic source confirms constructor/sample
edges:

```text
mean=0.0 shape=1.0 err=MeanNegativeOrNull
mean=inf shape=1.0 ok sample=NaN
mean=2.5 shape=inf ok sample=NaN
mean=inf shape=inf ok sample=NaN
mean=NaN shape=1.0 err=MeanNegativeOrNull
mean=1.0 shape=NaN err=ShapeNegativeOrNull
```

## Implementation

- `InverseGaussian(T)` and `VectorInverseGaussian` now accept positive infinite
  mean and shape values when the local `rand_distr` constructor accepts them.
- Finite-mean `shape == +inf` no longer short-circuits as an Alea point mass;
  scalar/vector samples and fills consume the StandardNormal plus uniform draw
  shape and produce `NaN` like local `rand_distr`.
- Positive infinite mean with finite or infinite shape also preserves the same
  draw shape and produces `NaN`.
- Alea's existing `mean == 0` no-consume boundary point-mass extension remains
  accepted and documented as a parity-plus deviation from local Rust.
- Focused tests cover scalar/vector checked, unchecked, reusable, fill,
  direct-source, support/moment accessors, invalid NaN rejection, and stream
  consumption for infinite mean/shape states.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "inverse-gaussian"
1/5 distributions.test.degenerate inverse-gaussian helpers do not consume random stream...OK
2/5 distributions.test.inverse-gaussian infinity semantics matches local rand_distr...OK
3/5 distributions.test.degenerate normal-inverse-gaussian helpers do not consume random stream...OK
4/5 distributions.test.inverse-gaussian and rank samplers have plausible behavior...OK
5/5 root.test_0...OK
All 5 tests passed.
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
- Current conclusion: S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1157 follow-ups closed for current bar
- Next bar: S4-M1158 post-S4-M1157 exact/default dense SIMD, broader runtime, or new local Rust gap
$ zig build rand-status-json
  "latest_validate_local_evidence": "compare/results/s4-m1157-inverse-gaussian-infinity.md"
$ zig build rand-status-schema-version
1
$ zig build rand-status-self-test
rand-status self-test ok
$ zig test src/distributions.zig --test-filter "inverse-gaussian infinity"
1/2 distributions.test.inverse-gaussian infinity semantics matches local rand_distr...OK
2/2 root.test_0...OK
All 2 tests passed.
$ zig build validate-local
rand_distr standard-normal: 29.8 M samples/s checksum=-3.640
rand_distr standard-normal f32: 28.7 M samples/s checksum=-3.640
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
apicheck ok
roadmapcheck ok
examplecheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M1157 is closed for the current bar: InverseGaussian infinite-parameter
sampling now matches local `rand_distr` NaN output and draw shape while Alea's
zero-mean point-mass extension remains. This is not whole-goal completion;
S4-M1158 remains active.
