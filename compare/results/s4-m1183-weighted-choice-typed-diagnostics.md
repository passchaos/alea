# S4-M1183 WeightedChoice Typed Diagnostics

## Gap

S4-M1180 added typed static weighted diagnostics to `AliasTable(Weight)` /
`WeightedIndex(Weight)`, and S4-M1182 refreshed the local Rust manifests around
those accessors. `seq.WeightedChoice(T, Weight)` wraps `AliasTable(Weight)` for
reusable item choices, but still exposed only `f64` weight diagnostics. That made
item-weighted workflows less ergonomic than the underlying static sampler when
callers needed the original `Weight` type, even though local Rust
`WeightedIndex::weight`, `weights`, and `total_weight` preserve the weight type.

## Change

`WeightedChoice(T, Weight)` now forwards the typed static weighted diagnostics
from its `AliasTable(Weight)`:

- `typedTotalWeight` / `totalWeightValue`
- `typedWeights` / `typedWeightsInto`
- `weightsValue` / `weightsValueInto`
- `typedWeightAt` / `typedWeight`
- `weightValueAt` / `weightValue`
- `typedWeightIter` / `weightValueIter`

The existing `f64` `totalWeight`, `weights`, `weightsInto`, `weightAt`,
`weight`, and `weightIter` APIs remain unchanged for probability and normalized
diagnostic workflows.

## Validation

```text
$ zig test src/seq.zig --test-filter "WeightedChoice typed weight diagnostics"
1/1 seq.test.WeightedChoice typed weight diagnostics preserve original weight type...OK
All 1 tests passed.
```

Additional validation:

```text
$ zig test src/seq.zig --test-filter "weighted choice"
1/20 seq.test.fillChooseWeightedBy fills accessor weighted choices...OK
...
20/20 root.test_0...OK
All 20 tests passed.

$ zig build roadmapcheck
roadmapcheck ok

$ zig build toolingcheck
toolingcheck ok

$ zig build rand-status-self-test
rand-status self-test ok

$ zig build validate-local
rand_distr standard-normal: 42.8 M samples/s checksum=-3.640
rand_distr standard-normal f32: 39.1 M samples/s checksum=-3.640
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
rand_bench_smoke self-test ok
runtimecheck ok: no additional runtime runner available

$ git diff --check
```

## Result

S4-M1183 is closed for the current bar: reusable `WeightedChoice` item samplers
now preserve and expose typed weight diagnostics consistently with the underlying
`AliasTable` / `WeightedIndex` static sampler. This is a local Rust ergonomics
and diagnostics closure, not whole-goal completion; S4-M1184 remains active.
