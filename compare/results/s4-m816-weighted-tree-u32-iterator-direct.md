# S4-M816 Weighted Tree U32 Iterators Direct Checked Sampling

## Gap

S4-M807 optimized dynamic weighted-tree bulk index fills. The compact
`WeightedTree.U32IndexIterator.nextValue` and `WeightedIntTree.U32IndexIterator`
scalar paths still routed each item through `sampleU32From`, which then forwarded
to the checked sampler.

## Local `rand_distr` Baseline

Dynamic weighted-tree iterator workflows sample indexes from the reusable tree.
Alea's compact `u32` dynamic-tree iterators should call the checked compact tree
sampler directly after iterator construction has already validated state and
width.

## Implementation

- `src/distributions.zig` updates `WeightedTree.U32IndexIterator.nextValue` to
  call `sampleU32CheckedFrom` directly.
- `src/distributions.zig` mirrors the change for `WeightedIntTree`.
- Focused tests compare compact iterator `next()` output with
  `sampleU32CheckedFrom` under identical seeds for generic and integer weighted
  trees, proving stream shape stays aligned.

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
examplecheck ok
toolingcheck ok
roadmapcheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M816 is closed for the current bar: dynamic `WeightedTree` and
`WeightedIntTree` compact u32 iterator scalar `next()` calls now avoid the
`sampleU32From` wrapper and call the checked tree sampler directly while
preserving stream shape. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
