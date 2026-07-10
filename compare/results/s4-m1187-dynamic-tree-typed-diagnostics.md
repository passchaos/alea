# S4-M1187 Dynamic Weighted Tree Typed Diagnostics

## Gap

S4-M1180 added typed static weighted diagnostics to `AliasTable` /
`WeightedIndex`, and S4-M1183 extended those typed diagnostics to reusable
`seq.WeightedChoice`. Dynamic weighted trees still exposed generic tree weights
as `f64` and integer-tree weights as `u64`, while local
`rand_distr::weighted::WeightedTreeIndex::get` returns the original `W` type.
This left a diagnostics ergonomics gap for users who update/push/pop dynamic
weights and want the original Zig `Weight` type back.

## Change

`WeightedTree(Weight)` and `WeightedIntTree(Weight)` now store original typed
weights alongside their sampling subtotals and expose:

- `typedWeightAt` / `typedWeight`
- `weightValueAt` / `weightValue`
- `getValue`
- `typedWeights` / `typedWeightsInto`
- `weightsValue` / `weightsValueInto`
- `typedWeightIter` / `weightValueIter`
- `popValue` / `typedPop`

The typed sidecar is maintained across `init`, `initBy`, `initByIndex`, `push`,
`pop`, `update`, `updateMany` / `updateWeights`, `updateAll`, `updateAllBy`,
`updateAllByIndex`, `clone`, `eql`, and `{f}` formatting. Existing `f64` /
`u64` diagnostic APIs remain unchanged.

## Validation

```text
$ zig test src/distributions.zig --test-filter "typed diagnostics preserve original"
1/2 distributions.test.weighted tree typed diagnostics preserve original weights...OK
2/2 distributions.test.weighted int tree typed diagnostics preserve original weight type...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "weighted tree"
1/21 distributions.test.weighted tree default constructors mirror local Rust default...OK
...
21/21 root.test_0...OK
All 21 tests passed.

$ zig test src/distributions.zig --test-filter "weighted int tree"
1/7 distributions.test.weighted int tree supports dynamic updates...OK
...
7/7 root.test_0...OK
All 7 tests passed.
```

Repository validation while closing this bar:

```text
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
...
apicheck ok
distcheck ok
statcheck ok
practrand self-test ok
rand-status self-test ok
profilecheck ok
distcheck ok
```

## Result

S4-M1187 is closed for the current bar: dynamic weighted trees now preserve and
expose typed weight diagnostics consistently with local Rust `WeightedTreeIndex`
`get` workflows and with Alea's static weighted samplers. This is a local Rust
diagnostics ergonomics closure, not whole-goal completion; S4-M1188 remains
active.
