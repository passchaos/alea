# S4-M748 Weighted Tree Owned U32 Index Prevalidation

## Gap

S4-M746 and S4-M747 tightened allocation-returning compact `u32` index helpers
for unweighted choice samplers and static alias tables. Dynamic `WeightedTree`
and `WeightedIntTree` still allocated output buffers before compact-width
validation in their owned `u32` index helpers.

Dynamic compact weighted-index outputs should reject oversized populations before
allocation and random-stream use, matching scalar, fill, fixed-array, and checked
iterator compact `u32` paths.

## Local `rand_distr` Baseline

The local Rust `rand_distr` weighted tree workflow is index-oriented and uses
platform-sized indexes. Alea's compact `u32` dynamic-tree index outputs are a
Zig-native extension, so populations larger than `u32` must fail deterministically
as `error.InvalidParameter` before allocation or stream consumption.

## Coverage Added

`src/distributions.zig` now prevalidates before allocation:

- `WeightedTree(Weight).indicesU32From`;
- `WeightedTree(Weight).indicesU32CheckedFrom`;
- `WeightedIntTree(Weight).indicesU32From`;
- `WeightedIntTree(Weight).indicesU32CheckedFrom`.

The focused dynamic-tree iterator test already builds fake oversized trees for
compact iterator width coverage. It now also verifies each owned compact helper
returns `error.InvalidParameter`, does not trigger a failing allocator, and leaves
the random stream unchanged.

The fake trees are never sampled or deinitialized; they only exercise length
prevalidation without impossible allocation.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "weighted tree iterators produce repeated indices"
1/2 distributions.test.weighted tree iterators produce repeated indices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
toolingcheck ok
apicheck ok
examplecheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M748 is closed for the current bar: dynamic `WeightedTree` and
`WeightedIntTree` allocation-returning compact `u32` index outputs now reject
oversized trees before allocation or random-stream use. This is
reliability/validation work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
