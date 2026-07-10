# S4-M1189 Dynamic Weighted Tree Typed Totals

## Gap

S4-M1187 added typed single-weight, bulk-weight, iterator, and pop diagnostics to
`WeightedTree(Weight)` and `WeightedIntTree(Weight)`, but dynamic weighted trees
still only exposed accumulated totals as `f64` / `u64` via `totalWeight()`.
Static weighted samplers already had typed total diagnostics through
`AliasTable(Weight).typedTotalWeight()` / `totalWeightValue()`, matching local
Rust `rand::distr::weighted::WeightedIndex::total_weight()` workflows. Dynamic
Alea users who update/push/pop weights still needed a typed total echo when the
original Zig `Weight` type is the desired diagnostics type.

## Change

`WeightedTree(Weight)` and `WeightedIntTree(Weight)` now expose:

- `typedTotalWeight() Error!Weight`
- `totalWeightValue() Error!Weight`

The methods sum the typed sidecar added in S4-M1187, so totals reflect the
original `Weight` type across `init`, `initBy`, `initByIndex`, `push`, `pop`,
`update`, `updateMany` / `updateWeights`, `updateAll`, `updateAllBy`, and
`updateAllByIndex`. Integer typed totals report `Overflow` when the original
`Weight` type cannot represent the typed diagnostic total, while existing
sampling totals (`f64` for `WeightedTree`, `u64` for `WeightedIntTree`) remain
unchanged.

## Validation

```text
$ zig test src/distributions.zig --test-filter "typed diagnostics preserve original"
1/2 distributions.test.weighted tree typed diagnostics preserve original weights...OK
2/2 distributions.test.weighted int tree typed diagnostics preserve original weight type...OK
All 2 tests passed.
```

Repository validation while closing this bar:

```text
$ zig test src/distributions.zig --test-filter "weighted tree"
All 21 tests passed.

$ zig test src/distributions.zig --test-filter "weighted int tree"
All 7 tests passed.

$ zig test src/distributions.zig --test-filter "weighted"
All 127 tests passed.

$ zig build rand-status-self-test
rand-status self-test ok

$ zig build roadmapcheck
roadmapcheck ok

$ zig build toolingcheck
toolingcheck ok

$ git diff --check
(no output)

$ zig build validate-local
rand_distr standard-normal: 36.9 M samples/s checksum=-3.640
rand_distr standard-normal f32: 36.3 M samples/s checksum=-3.640
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
runtimecheck ok: no additional runtime runner available
apicheck ok
toolingcheck ok
readmecheck ok
examplecheck ok
statcheck ok
distcheck ok
profilecheck ok
rand-status self-test ok
```

## Result

S4-M1189 is closed for the current bar: dynamic weighted trees now expose typed
total-weight diagnostics consistently with Alea's static weighted samplers and
with typed dynamic-tree weight diagnostics. This is a diagnostics ergonomics
closure, not whole-goal completion; S4-M1190 remains active.
