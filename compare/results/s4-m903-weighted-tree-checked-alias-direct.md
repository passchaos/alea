# S4-M903 Weighted Tree Checked Alias Direct Sampler Paths

## Gap

Dynamic `WeightedTree` and `WeightedIntTree` checked scalar/index/u32 sample
aliases still layered through checked wrapper helpers. Earlier milestones made
unchecked dynamic tree aliases direct, but the checked aliases could still
validate once and call the selected tree sampler directly instead of entering
another checked wrapper.

## Local `rand` Baseline

Local Rust `rand`/`rand_distr` weighted-index workflows sample indexes from a
reusable weighted sampler and let callers map those indexes as needed. Alea's
dynamic weighted trees provide mutable weighted-index samplers that extend this
model to updateable trees. Checked scalar and compact aliases should preserve
validation, single-positive no-consume behavior, and stream shape without extra
wrapper dispatch.

## Implementation

- `src/distributions.zig` updates `WeightedTree.sampleIndexCheckedFrom`,
  `sampleU32CheckedFrom`, and `sampleIndexU32CheckedFrom` to validate totals /
  output size once and then call `sampleWithTotalFrom` directly.
- `src/distributions.zig` applies the same direct checked alias structure to
  `WeightedIntTree` with integer total validation.
- The focused weighted-tree alias test now compares checked scalar and compact
  aliases against direct checked sample helpers for both floating and integer
  dynamic trees while existing coverage preserves invalid and single-positive
  no-consume behavior.

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
readmecheck ok
roadmapcheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M903 is closed for the current bar: dynamic `WeightedTree` and
`WeightedIntTree` checked scalar/index/u32 sample aliases now avoid checked
wrapper aliases while preserving validation, stream shape, and checked error
behavior. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
