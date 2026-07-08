# S4-M935 Choice Checked Array From Direct Paths

## Gap

Reusable `Choice` direct-source checked fixed-array helpers still routed through
unchecked direct-source array wrappers for pointer and index outputs. Checked
direct-source fills were already available, so the checked array helpers can
build their stack arrays and fill them directly while preserving stream shape and
checked validation.

## Local `rand` Baseline

Local Rust `rand` slice-choice workflows commonly collect repeated direct RNG
samples into caller-owned or stack-owned arrays. Alea's reusable `Choice` adds
fixed-array pointer, value, `usize` index, and compact `u32` index helpers over
direct RNG sources; checked direct-source constructors should preserve validation
while avoiding unchecked array wrapper aliases.

## Implementation

- `src/seq.zig` updates `Choice.ptrArrayCheckedFrom` to allocate the fixed array
  on the stack and call checked direct-source pointer fill directly.
- `src/seq.zig` updates `Choice.indexArrayCheckedFrom` to allocate the fixed array
  on the stack and call checked direct-source index fill directly.
- `src/seq.zig` updates `Choice.indexArrayU32CheckedFrom` to allocate the fixed
  array on the stack and call checked direct-source compact-index fill directly,
  preserving compact `u32` length validation.
- `Choice.valueArrayCheckedFrom` was already direct and remains the value-output
  reference path for this family.
- Focused tests compare checked direct-source arrays against unchecked arrays and
  checked facade arrays for stream shape, and cover compact-index rejection.

## Validation

Focused reusable Choice tests:

```text
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "Choice owned u32 indices reject oversized population before allocation"
1/3 seq.test.Choice owned u32 indices reject oversized population before allocation...OK
2/3 seq.test.WeightedChoice owned u32 indices reject oversized population before allocation...OK
3/3 root.test_0...OK
All 3 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M935 is closed for the current bar: reusable `Choice` checked direct-source
fixed-array helpers now avoid unchecked direct-source array wrapper aliases while
preserving stream shape and checked behavior. This is reliability/ergonomics work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
