# S4-M1180 Typed Static Weighted Diagnostics

## Gap

Local Rust `rand::distr::weighted::WeightedIndex` preserves the original weight
type for diagnostics: `weight(index) -> Option<X>`, `weights() ->
WeightedIndexIter<'_, X>`, and `total_weight() -> X`. Alea's static
`AliasTable(Weight)` / `WeightedIndex(Weight)` previously exposed f64
reconstructions only, which was sufficient for probabilities but not for
Zig-native typed configuration echo/debugging.

## Implementation

- `AliasTable(Weight)` now stores a typed copy of its accepted weights alongside
  its f64 alias-table internals.
- Added typed single-weight diagnostics:
  - `typedWeightAt`, `typedWeight`, `weightValueAt`, `weightValue`.
- Added typed bulk diagnostics:
  - `typedWeights`, `typedWeightsInto`, `weightsValue`, `weightsValueInto`.
- Added typed total diagnostics:
  - `typedTotalWeight`, `totalWeightValue`.
- Added typed lazy iterator diagnostics:
  - `TypedWeightIterator`, `typedWeightIter`, and `weightValueIter`, including
    size hints, `fill`, `clone`, and `{f}` formatting.
- Focused tests cover typed total/single/bulk/iterator diagnostics and ensure
  `updateAt` / `updateWeights` preserve typed values.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "typed weight diagnostics"
1/1 distributions.test.alias table typed weight diagnostics mirror Rust weighted index accessors...OK
All 1 tests passed.
```

## Validation

```text
$ zig test src/distributions.zig --test-filter "WeightedIndex alias"
1/2 distributions.test.WeightedIndex alias mirrors AliasTable...OK
2/2 root.test_0...OK
All 2 tests passed.
```

## Full validation

```text
$ git diff --check

$ zig test src/distributions.zig --test-filter "typed weight diagnostics"
1/1 distributions.test.alias table typed weight diagnostics mirror Rust weighted index accessors...OK
All 1 tests passed.

$ zig test src/distributions.zig --test-filter "weighted"
1/125 distributions.test.weighted samplers clone and equality mirror local Rust derives...OK
...
125/125 seq.test.sampleIteratorWeightedArray returns fixed-size weighted iterator samples...OK
All 125 tests passed.

$ zig build apicheck
apicheck ok

$ zig build roadmapcheck
roadmapcheck ok

$ zig build toolingcheck
toolingcheck ok

$ zig build rand-status-self-test
rand-status self-test ok

$ zig build test
readmecheck ok
roadmapcheck ok
apicheck ok
toolingcheck ok
examplecheck ok

$ zig build validate-local
rand_bench_smoke self-test ok
runtimecheck ok: no additional runtime runner available
"current_conclusion": "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1180 follow-ups closed for current bar"
"remaining_blocker": "S4-M1181 post-S4-M1180 next product bar"
"latest_validate_local_evidence": "compare/results/s4-m1180-typed-static-weighted-diagnostics.md"
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
rand_distr standard-normal: 41.0 M samples/s checksum=-3.640
rand_distr standard-normal f32: 39.1 M samples/s checksum=-3.640
```

## Result

S4-M1180 is closed for the current bar: Alea static weighted samplers now cover
local Rust `WeightedIndex` typed weight/weights/total-weight diagnostics while
keeping f64 probability internals and existing probability export APIs. This is
not whole-goal completion; S4-M1181 remains active.
