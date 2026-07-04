# S4-M102 Rng Repeated Index Choice Batches

Date: 2026-07-04

Purpose: add caller-owned and allocation-returning repeated index-choice helpers
for `Rng`. This complements one-shot `chooseIndex` / `chooseIndexU32`, S4-M63
and S4-M76 one-shot index helpers, reusable `Choice.indices*`, and no-replacement
sequence samplers.

## Rust rand Comparison

Rust `rand` supports repeated with-replacement choices through iterator loops and
slice choice APIs, while no-replacement sampling is a distinct workflow. Alea
already had one-shot `chooseIndex` / `chooseIndexU32` and no-replacement
`sampleIndices*`; S4-M102 adds direct Zig-native caller-owned and owned repeated
index-choice batches for the with-replacement case.

## Change

Added repeated index choice helpers in `src/rng.zig`:

- `Rng.fillChooseIndex(dest, length)`;
- `Rng.fillChooseIndexFrom(source, dest, length)`;
- `Rng.fillChooseIndexChecked(dest, length)`;
- `Rng.fillChooseIndexCheckedFrom(source, dest, length)`;
- `Rng.chooseIndexBatch(allocator, count, length)`;
- `Rng.chooseIndexBatchFrom(source, allocator, count, length)`;
- `Rng.chooseIndexBatchChecked(allocator, count, length)`;
- `Rng.chooseIndexBatchCheckedFrom(source, allocator, count, length)`;
- compact `u32` equivalents for each helper.

The checked helpers return zero-count slices before validating empty inputs,
return empty-input errors before allocating/drawing for positive counts, allocate
before consuming randomness, and fill singleton choices with zeroes without
consuming randomness.

Updated adoption/docs:

- `examples/basic.zig` prints `index choice batch` and
  `u32 index choice batch` rows;
- `tools/examplecheck.zig` guards the basic example tokens;
- `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, and
  `README.md` list the new APIs;
- `compare/results/linux-no-known-gaps-audit.md` includes S4-M102 evidence.

## Validation

Commands for final validation:

```sh
git diff --check
zig build test
zig build run-basic
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- facade/direct stream-shape parity for usize/u32 owned batches and checked
  owned batches;
- singleton no-consume behavior for usize/u32 owned batches;
- zero-count checked batches returning before empty-input validation/allocation;
- invalid positive-count empty choices returning before allocation or stream
  consumption;
- allocation-failure paths without stream consumption.

## S4-M102 Decision

S4-M102 is closed for the current repeated index choice batch bar: callers can
now fill caller-owned index buffers or request owned usize/u32 index slices for
with-replacement repeated choices.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
