# S4-M1035 Native F32 Normal Facade Direct Paths

## Gap

Reusable scalar/vector native-f32 normal samplers still routed facade `sample` /
`fill` through `sampleFrom` / `fillFrom`. The native-f32 top-level facade helpers
already drive facade `Rng` directly and preserve the stable snapshot contract, so
these reusable samplers can call those facade helpers directly.

## Local `rand` / `rand_distr` Baseline

The local `rand` checkout remains the primary baseline, while Alea's native-f32
normal surface is an explicit opt-in throughput profile rather than a Rust API
copy. For this gap the relevant comparison is the reusable-sampler contract: a
reusable sampler should drive the provided RNG directly and avoid avoidable
wrapper hops while preserving documented snapshot-sensitive output mappings.

## Implementation

- `src/distributions.zig` updates `NormalNativeF32.sample` and
  `NormalNativeF32.fill` to call `normalNativeF32` and `fillNormalNativeF32`
  facade helpers directly.
- `src/distributions.zig` updates `VectorNormalNativeF32.sample` and
  `VectorNormalNativeF32.fill` to call the vector native-f32 facade helpers
  directly.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows.

## Validation

Focused native-f32 tests:

```text
$ zig test src/distributions.zig --test-filter "native f32 parameterized samplers have stable snapshots"
1/3 distributions.test.native f32 parameterized samplers have stable snapshots...OK
2/3 distributions.test.vector native f32 parameterized samplers have stable snapshots...OK
3/3 root.test_0...OK
All 3 tests passed.

$ zig test src/distributions.zig --test-filter "vector native f32 parameterized samplers have stable snapshots"
1/2 distributions.test.vector native f32 parameterized samplers have stable snapshots...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "native f32 standard samplers have stable snapshots"
1/2 distributions.test.native f32 standard samplers have stable snapshots...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
roadmapcheck ok
toolingcheck ok
examplecheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M1035 is closed for the current bar: reusable scalar/vector native-f32 Normal
facade sample/fill helpers now avoid direct-source wrapper aliases while
preserving snapshot-sensitive output semantics. This is reliability/ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
