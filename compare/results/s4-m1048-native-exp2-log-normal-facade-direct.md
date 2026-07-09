# S4-M1048 Native Exp2 F32 LogNormal Facade Direct Paths

## Gap

Reusable scalar/vector native-exp2-f32 LogNormal samplers still routed facade
`sample` / `fill` through `sampleFrom` / `fillFrom`. The native-exp2 top-level
facade helpers already drive facade `Rng` directly and preserve their
snapshot-sensitive output contract, so reusable native-exp2 LogNormal samplers can
call those facade helpers directly.

## Local `rand` / `rand_distr` Baseline

The local `rand` checkout remains the primary baseline, while Alea's native-exp2
log-normal surface is an explicit opt-in throughput/approximation profile rather
than a Rust API copy. For this gap the relevant comparison is the reusable-sampler
contract: a reusable sampler should drive the provided RNG directly and avoid
avoidable wrapper hops while preserving documented snapshot-sensitive output
mappings.

## Implementation

- `src/distributions.zig` updates `LogNormalNativeExp2F32.sample` and
  `LogNormalNativeExp2F32.fill` to call native-exp2 log-normal facade helpers
  directly.
- `src/distributions.zig` updates `VectorLogNormalNativeExp2F32.sample` and
  `VectorLogNormalNativeExp2F32.fill` to call vector native-exp2 log-normal
  facade helpers directly.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows.

## Validation

Focused native-exp2 LogNormal test:

```text
$ zig test src/distributions.zig --test-filter "native exp2 f32 log-normal has stable snapshots"
1/2 distributions.test.native exp2 f32 log-normal has stable snapshots...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
toolingcheck ok
readmecheck ok
roadmapcheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M1048 is closed for the current bar: reusable scalar/vector native-exp2-f32
LogNormal facade sample/fill helpers now avoid direct-source wrapper aliases
while preserving snapshot-sensitive output semantics. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
