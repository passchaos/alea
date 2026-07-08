# S4-M909 Weighted Tree Facade Sample Aliases Direct Paths

## Gap

Dynamic `WeightedTree` and `WeightedIntTree` facade sample/index/u32 helpers still
routed through checked facade wrappers before reaching the tree sampler. S4-M903
made direct-source checked aliases direct, but facade aliases retained extra
wrapper hops.

## Local `rand` Baseline

Local Rust `rand`/`rand_distr` weighted-index workflows sample indexes directly
through an RNG reference. Alea's dynamic weighted trees extend this model with
mutable weighted-index samplers, so facade sample/index/u32 helpers should
validate and execute tree sampling directly while preserving stream shape and
single-positive no-consume behavior.

## Implementation

- `src/distributions.zig` updates `WeightedTree` facade `sample`, `sampleIndex`,
  `sampleU32`, `sampleIndexU32`, `sampleChecked`, `sampleIndexChecked`,
  `sampleU32Checked`, and `sampleIndexU32Checked` to validate once and call
  `sampleWithTotalFrom` directly.
- `src/distributions.zig` applies the same direct facade structure to
  `WeightedIntTree` with integer total validation.
- The focused weighted-tree alias test compares facade sample/index/u32 aliases
  for both floating and integer dynamic trees while existing coverage preserves
  invalid and single-positive no-consume behavior.

## Validation

Focused weighted-tree alias test:

```text
$ zig test src/distributions.zig --test-filter "weighted tree index aliases mirror sample helpers"
1/2 distributions.test.weighted tree index aliases mirror sample helpers...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M909 is closed for the current bar: dynamic `WeightedTree` and
`WeightedIntTree` facade sample/index/u32 aliases now avoid checked facade wrapper
aliases while preserving validation, stream shape, and checked error behavior.
This is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
