# S4-M62 Caller-Owned Pointer Example Refresh

Date: 2026-07-04

Purpose: refresh the focused caller-owned sampling example so adoption guidance
covers the pointer-buffer APIs added after S4-M48. The example now demonstrates
allocation-predictable pointer workflows for unweighted item subsets, reservoir
samples, and weighted no-replacement samples.

## Change

Updated `examples/caller_owned_sampling.zig` to print:

- `chooseMultiplePtrsInto` caller-owned const-pointer item subsets;
- `reservoirSamplePtrsInto` caller-owned const-pointer reservoir samples;
- `sampleWeightedPtrsInto` caller-owned weighted const-pointer samples;
- the existing caller-owned index, value, iterator, weighted, and scratch-buffer
  workflows.

Updated docs:

- `docs/examples.md` describes caller-owned index/item/pointer/iterator buffers;
- `README.md` mentions caller-owned pointer adoption examples;
- roadmap/audit files include this evidence.

## Validation

Commands:

```sh
git diff --check
zig build test
zig build run-caller-owned-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

The focused run prints the new pointer-buffer rows and keeps the existing
caller-owned index/value/iterator/weighted rows under the `zig build examples`
and `zig build validate` gates.

## S4-M62 Decision

S4-M62 is closed for the current caller-owned pointer adoption bar: the focused
caller-owned example now demonstrates the pointer-buffer APIs that materially
improve allocation-predictable workflows for large or mutable item sets.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
