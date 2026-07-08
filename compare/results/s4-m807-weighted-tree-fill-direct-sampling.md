# S4-M807 Weighted Tree Fill Direct Sampling Paths

## Gap

Dynamic `WeightedTree` and `WeightedIntTree` fill paths already cached total
weight once per call, but each output slot still called `sampleWithTotalFrom`.
That re-entered a scalar wrapper for every slot before running the tree walk.

## Local `rand_distr` Baseline

Rust `rand_distr` weighted tree workflows sample indexes from a reusable dynamic
weighted structure. Alea exposes caller-owned dynamic-tree index fills; these
bulk APIs should run the repeated tree walks directly while preserving the same
random stream shape as scalar sampling.

## Implementation

- `src/distributions.zig` adds direct `fillWithTotalFrom` and
  `fillU32WithTotalFrom` loops for `WeightedTree`, and routes scalar
  `sampleWithTotalFrom` through the one-element fill helper.
- `src/distributions.zig` mirrors the same direct loops for `WeightedIntTree`.
- Focused tests compare usize/u32 fills against scalar `sampleCheckedFrom` /
  `sampleU32CheckedFrom` loops under identical seeds for both generic f64 and
  integer weighted trees.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "weighted tree u32 sampling helpers mirror usize helpers"
1/2 distributions.test.weighted tree u32 sampling helpers mirror usize helpers...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
toolingcheck ok
apicheck ok
roadmapcheck ok
examplecheck ok
readmecheck ok
```

## Result

S4-M807 is closed for the current bar: dynamic weighted tree usize/u32 index fills
now avoid per-slot scalar sample wrapper calls and run direct tree-walk sampling
loops while preserving stream shape. This is reliability/ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
