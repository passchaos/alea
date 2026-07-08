# S4-M933 WeightedChoice Checked Owned From Direct Paths

## Gap

Reusable `WeightedChoice` direct-source checked allocation-returning helpers still
routed through unchecked direct-source owned wrappers. Checked direct-source
fills were already available, so the checked owned helpers can allocate their
output slices and fill them directly while preserving stream shape,
allocation-failure behavior, and checked prevalidation.

## Local `rand` Baseline

Local Rust `rand` weighted-selection workflows commonly collect repeated
weighted samples into owned containers after direct RNG-driven sampling through
`WeightedIndex` or slice `choose_weighted` helpers. Alea's reusable
`WeightedChoice` adds allocation-returning pointer, value, `usize` index, and
compact `u32` index helpers over direct RNG sources; the checked direct-source
variants should preserve validation while avoiding unchecked owned wrapper
aliases.

## Implementation

- `src/seq.zig` updates `WeightedChoice.ptrsCheckedFrom` to allocate the pointer
  slice and call checked direct-source pointer fill directly.
- `src/seq.zig` updates `WeightedChoice.valuesCheckedFrom` to handle zero-length
  and empty-enum prevalidation, allocate the value slice, and call checked
  direct-source value fill directly.
- `src/seq.zig` updates `WeightedChoice.indicesCheckedFrom` and
  `WeightedChoice.indicesU32CheckedFrom` to allocate index slices and call checked
  direct-source index fills directly, preserving compact `u32` length validation.
- Focused tests compare each checked direct-source owned helper against the
  matching unchecked direct-source owned helper for stream shape and cover the
  oversized compact-index preallocation rejection path.

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
readmecheck ok
apicheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M933 is closed for the current bar: reusable `WeightedChoice` checked
direct-source owned helpers now avoid unchecked direct-source owned wrapper
aliases while preserving stream shape, allocation behavior, and checked behavior.
This is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
