# S4-M1040 Vector Approx-Log Exponential Facade Direct Paths

## Gap

Reusable `VectorExponentialApproxLogF32` facade `sample` / `fill` still routed
through `sampleFrom` / `fillFrom`. The approximate-log top-level facade helpers
already drive facade `Rng` directly and preserve their explicit output-mapping
contract, so reusable vector approximate-log Exponential samplers can call those
facade helpers directly.

## Local `rand` / `rand_distr` Baseline

The local `rand` checkout remains the primary baseline, while Alea's
approximate-log vector exponential surface is an explicit opt-in throughput
profile rather than a Rust API copy. For this gap the relevant comparison is the
reusable-sampler contract: a reusable sampler should drive the provided RNG
directly and avoid avoidable wrapper hops while preserving documented
snapshot-sensitive output mappings.

## Implementation

- `src/distributions.zig` updates `VectorExponentialApproxLogF32.sample` to call
  `vectorStandardExponentialApproxLogF32` through facade `Rng` directly and scale
  by the cached inverse rate.
- `src/distributions.zig` updates `VectorExponentialApproxLogF32.fill` to call
  `fillVectorStandardExponentialApproxLogF32` through facade `Rng` directly and
  scale the scalar lanes in place.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows.

## Validation

Focused approximate-log/vector native-f32 tests:

```text
$ zig test src/distributions.zig --test-filter "native f32 standard samplers have stable snapshots"
1/2 distributions.test.native f32 standard samplers have stable snapshots...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "vector native f32 parameterized samplers have stable snapshots"
1/2 distributions.test.vector native f32 parameterized samplers have stable snapshots...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "vector approximate-log f32 exponential has stable snapshots"
1/2 distributions.test.vector approximate-log f32 exponential has stable snapshots...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
roadmapcheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
apicheck ok
```

## Result

S4-M1040 is closed for the current bar: reusable vector approximate-log f32
Exponential facade sample/fill helpers now avoid direct-source wrapper aliases
while preserving snapshot-sensitive output semantics. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
