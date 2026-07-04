# S4-M48 Caller-Owned Sampling Adoption Example

Date: 2026-07-04

Purpose: make the recent caller-owned and scratch-buffer sequence APIs easier to
discover. S4-M35 through S4-M47 added many allocation-predictable helpers; this
milestone adds a focused runnable example that demonstrates them together.

## Change

Added `examples/caller_owned_sampling.zig` and build step:

```sh
zig build run-caller-owned-sampling
```

The example demonstrates:

- `sampleIndicesIntoCheckedFrom` for caller-owned `usize` index buffers;
- `sampleIndicesU32IntoCheckedFrom` for caller-owned compact `u32` index buffers;
- `chooseMultipleIntoFrom` for caller-owned item subset buffers;
- `reservoirSampleIntoFrom` for caller-owned slice reservoir buffers;
- `sampleIteratorIntoFrom` for caller-owned streaming iterator buffers;
- `sampleWeightedIndicesIntoFrom` for weighted index buffers with caller-owned
  key scratch;
- `sampleWeightedIntoFrom` for weighted item buffers with caller-owned index/key
  scratch;
- `sampleIteratorWeightedIntoFrom` for weighted iterator buffers with
  caller-owned key scratch.

Wired the example into:

- `zig build examples` and therefore `zig build validate`;
- `docs/examples.md`;
- `docs/core-guide.md`;
- `docs/api-reference.md`;
- `docs/tooling.md`;
- `tools/examplecheck.zig`;
- `tools/toolingcheck.zig`.

## Validation

Commands:

```sh
zig build run-caller-owned-sampling
zig build examplecheck
zig build toolingcheck
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

## S4-M48 Decision

S4-M48 is closed for the current caller-owned sampling adoption bar: recent
allocation-predictable sequence helpers now have a dedicated runnable example and
catalog/checker coverage.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
