# S4-M940 WeightedChoice U32 Array From Direct Path

## Gap

Reusable `WeightedChoice.indexArrayU32From` still routed through the checked
direct-source compact-array helper. The unchecked direct-source compact-array
helper already performs the required `u32` length validation through its fill
path, so it can construct the stack array and fill it directly instead of
routing through another array helper.

## Local `rand` Baseline

Local Rust `rand` weighted-selection workflows commonly collect repeated sampled
indexes into stack-owned arrays or caller-owned buffers through `WeightedIndex`
or slice `choose_weighted` helpers. Alea's reusable `WeightedChoice` adds a
compact `u32` fixed-array helper for direct RNG sources; it should be a
first-class direct-source array constructor rather than a wrapper around the
checked array helper.

## Implementation

- `src/seq.zig` updates `WeightedChoice.indexArrayU32From` to allocate the fixed
  `u32` array on the stack and call `fillIndicesU32From` directly.
- Focused tests compare compact `u32` direct arrays with checked direct arrays,
  facade arrays, and oversized-population rejection behavior.

## Validation

Focused reusable WeightedChoice tests:

```text
$ zig test src/seq.zig --test-filter "weighted choice sampler maps alias indexes to items"
1/2 seq.test.weighted choice sampler maps alias indexes to items...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "WeightedChoice owned u32 indices reject oversized population before allocation"
1/2 seq.test.WeightedChoice owned u32 indices reject oversized population before allocation...OK
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
apicheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M940 is closed for the current bar: reusable `WeightedChoice.indexArrayU32From`
now constructs and fills its compact direct-source fixed array directly while
preserving stream shape and checked length behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
