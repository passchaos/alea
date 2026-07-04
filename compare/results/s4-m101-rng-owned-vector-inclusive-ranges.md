# S4-M101 Rng Owned Vector Inclusive Integer Range Batches

Date: 2026-07-04

Purpose: add vector inclusive integer range helpers for `Rng`. This complements
`vectorRange`, S4-M92 vector half-open owned range batches, and S4-M100 scalar
inclusive integer range batches.

## Rust rand Comparison

Rust `rand` supports inclusive integer ranges through `random_range(a..=b)` and
repeated draws through iterators or loops. Alea already had vector half-open
`vectorRange` / `vectorRangeBatch` and scalar inclusive `rangeAtMostBatch`; S4-M101
adds Zig-native `@Vector` inclusive integer range helpers so vector-lane callers
can avoid manual loops and handle inclusive upper bounds directly.

## Change

Added vector inclusive integer range helpers in `src/rng.zig`:

- `Rng.vectorRangeAtMost(VectorType, min, max)`;
- `Rng.vectorRangeAtMostFrom(source, VectorType, min, max)`;
- `Rng.vectorRangeAtMostChecked(VectorType, min, max)`;
- `Rng.vectorRangeAtMostCheckedFrom(source, VectorType, min, max)`;
- `Rng.fillVectorRangeAtMost(VectorType, dest, min, max)`;
- `Rng.fillVectorRangeAtMostFrom(source, VectorType, dest, min, max)`;
- `Rng.fillVectorRangeAtMostChecked(VectorType, dest, min, max)`;
- `Rng.fillVectorRangeAtMostCheckedFrom(source, VectorType, dest, min, max)`;
- `Rng.vectorRangeAtMostBatch(VectorType, allocator, count, min, max)`;
- `Rng.vectorRangeAtMostBatchFrom(source, VectorType, allocator, count, min, max)`;
- `Rng.vectorRangeAtMostBatchChecked(VectorType, allocator, count, min, max)`;
- `Rng.vectorRangeAtMostBatchCheckedFrom(source, VectorType, allocator, count, min, max)`.

The helpers support integer vector types, preserve no-consume behavior for
degenerate `min == max` ranges, return zero-count checked batches before
validation, return invalid positive-count ranges before allocation/drawing, and
allocate before random-stream consumption.

Updated adoption/docs:

- `examples/range_sampling.zig` prints a `vectorRangeAtMostBatch i32x4 [-10,10]`
  row;
- `tools/examplecheck.zig` guards the range example token;
- `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, and
  `README.md` list the new APIs;
- `compare/results/linux-no-known-gaps-audit.md` includes S4-M101 evidence.

## Validation

Commands for final validation:

```sh
git diff --check
zig build test
zig build run-range-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- checked/unchecked `fillVectorRangeAtMost` stream-shape parity;
- checked/unchecked `vectorRangeAtMostBatch` stream-shape parity;
- zero-count checked batches returning before validation/allocation;
- invalid positive-count ranges returning before allocation or stream
  consumption;
- allocation-failure paths without stream consumption;
- degenerate `min == max` fill and owned batches not consuming randomness.

## S4-M101 Decision

S4-M101 is closed for the current vector inclusive integer range bar: callers can
sample one vector, fill caller-owned vector buffers, or request owned vector
slices for inclusive integer ranges directly.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
