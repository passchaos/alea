# S4-M893 Weighted Tree Index Aliases Direct Checked Paths

## Gap

Dynamic `WeightedTree` and `WeightedIntTree` index aliases still routed
`sampleIndexFrom` through `sampleFrom` and `sampleIndexU32From` through
`sampleU32From`, adding alias wrappers before reaching the checked tree sampling
paths.

## Local `rand` Baseline

Alea's dynamic weighted trees are parity-plus reusable weighted-index structures.
Their canonical checked sampling paths already encode the direct tree walk and
validation behavior, so the Rust-discoverable index aliases can call those paths
directly while preserving stream shape and unchecked alias semantics.

## Implementation

- `src/distributions.zig` updates both `WeightedTree` and `WeightedIntTree` so:
  - `sampleIndexFrom` calls `sampleCheckedFrom(source) catch unreachable` directly;
  - `sampleIndexU32From` calls `sampleU32CheckedFrom(source) catch unreachable`
    directly.
- Focused tests already compare dynamic tree alias stream shape and checked
  behavior for both generic and integer weighted trees.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "weighted tree index aliases mirror sample helpers"
1/2 distributions.test.weighted tree index aliases mirror sample helpers...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
roadmapcheck ok
examplecheck ok
readmecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M893 is closed for the current bar: dynamic weighted tree index aliases now
avoid redundant alias wrappers and reach checked sampling paths directly while
preserving stream shape. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
