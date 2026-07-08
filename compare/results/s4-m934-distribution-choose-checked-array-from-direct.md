# S4-M934 Distribution Choose Checked Array From Direct Paths

## Gap

Distribution-layer `Choose` direct-source checked fixed-array helpers still routed
through unchecked direct-source array wrappers for pointer and index outputs.
Checked direct-source fills were already available, so the checked array helpers
can build their stack arrays and fill them directly while preserving stream shape
and checked validation.

## Local `rand` Baseline

Local Rust `rand` slice-choice workflows commonly collect repeated direct RNG
samples into caller-owned or stack-owned arrays. Alea's distribution-layer
`Choose` adds fixed-array pointer, value, `usize` index, and compact `u32` index
helpers over direct RNG sources; checked direct-source constructors should
preserve validation while avoiding unchecked array wrapper aliases.

## Implementation

- `src/distributions.zig` updates `Choose.ptrArrayCheckedFrom` to allocate the
  fixed array on the stack and call checked direct-source pointer fill directly.
- `src/distributions.zig` updates `Choose.indexArrayCheckedFrom` to allocate the
  fixed array on the stack and call checked direct-source index fill directly.
- `src/distributions.zig` updates `Choose.indexArrayU32CheckedFrom` to allocate
  the fixed array on the stack and call checked direct-source compact-index fill
  directly, preserving compact `u32` length validation.
- `Choose.valueArrayCheckedFrom` was already direct and remains the value-output
  reference path for this family.
- Focused tests compare checked direct-source arrays against unchecked arrays and
  checked facade arrays for stream shape.

## Validation

Focused distribution Choose test:

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
readmecheck ok
apicheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M934 is closed for the current bar: distribution-layer `Choose` checked
direct-source fixed-array helpers now avoid unchecked direct-source array wrapper
aliases while preserving stream shape and checked behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
