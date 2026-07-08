# S4-M898 Distribution Choose Checked Sample Direct Index Paths

## Gap

Distribution-layer `Choose.sampleValueCheckedFrom`,
`Choose.sampleIndexCheckedFrom`, and `Choose.sampleIndexU32CheckedFrom` still
validated their checked preconditions and then routed through unchecked scalar
sample helpers. The unchecked helpers already mapped a uniform index into the
item slice directly, so the checked APIs could preserve the same stream shape
while avoiding the extra wrapper hop after validation.

## Local `rand` Baseline

Local Rust `rand` exposes slice choice workflows through `rand::seq`, especially
`IndexedRandom::choose` and related index-based sampling helpers. The reference
implementation samples a uniform in-bounds index and returns/copies the selected
item, while empty slices return a checked/optional failure before random draws.

Alea's distribution-layer `Choose` keeps Zig-native checked APIs and explicit
compact-index variants. For non-empty validated choices, the checked scalar paths
can draw the same uniform index and map directly to the selected item/index,
matching the slice-choice stream policy already used by unchecked samples.

## Implementation

- `src/distributions.zig` updates `Choose.sampleValueCheckedFrom` to keep
  empty-enum prevalidation and then directly execute singleton or uniform-index
  value mapping.
- `src/distributions.zig` updates `Choose.sampleIndexCheckedFrom` to directly
  execute singleton or uniform-index `usize` sampling.
- `src/distributions.zig` updates `Choose.sampleIndexU32CheckedFrom` to keep the
  oversized-population check and then directly execute singleton or uniform-index
  compact `u32` sampling.
- The focused distribution `Choose` test now compares checked scalar samples with
  helper-generated indexes for value, `usize`, and compact `u32` paths while
  existing coverage preserves checked error and no-consume behavior.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "distribution Choose sampler mirrors slice choices"
1/2 distributions.test.distribution Choose sampler mirrors slice choices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
examplecheck ok
roadmapcheck ok
readmecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M898 is closed for the current bar: distribution-layer `Choose` checked
scalar value/index/u32 samples now avoid unchecked sampling wrappers after
prevalidation while preserving stream shape, singleton behavior, and checked
error behavior. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
