# S4-M100 Rng Owned Inclusive Integer Range Batches

Date: 2026-07-04

Purpose: add caller-owned and allocation-returning inclusive integer range
helpers for `Rng`. This complements one-shot `intRangeAtMost`, Rust inclusive
`random_range` usage, S4-M87 half-open `rangeBatch`, and duration `AtMost`
batches.

## Rust rand Comparison

Rust `rand` supports inclusive integer ranges through `random_range(a..=b)`,
with repeated draws usually written through iterators or user loops. Alea already
had one-shot `intRangeAtMost` and half-open owned `rangeBatch`; S4-M100 adds
Zig-native caller-owned and owned-batch helpers for inclusive integer ranges,
including upper bounds such as `maxInt(T)` that cannot be represented by simply
adding one to a half-open upper endpoint.

## Change

Added inclusive integer range helpers in `src/rng.zig`:

- `Rng.fillRangeAtMost(T, dest, min, max)`;
- `Rng.fillRangeAtMostFrom(source, T, dest, min, max)`;
- `Rng.fillRangeAtMostChecked(T, dest, min, max)`;
- `Rng.fillRangeAtMostCheckedFrom(source, T, dest, min, max)`;
- `Rng.rangeAtMostBatch(T, allocator, count, min, max)`;
- `Rng.rangeAtMostBatchFrom(source, T, allocator, count, min, max)`;
- `Rng.rangeAtMostBatchChecked(T, allocator, count, min, max)`;
- `Rng.rangeAtMostBatchCheckedFrom(source, T, allocator, count, min, max)`.

The helpers support integer slices, preserve no-consume behavior for degenerate
`min == max` ranges, return zero-count checked batches before validation, return
invalid positive-count ranges before allocation/drawing, and allocate before any
random-stream consumption.

Updated adoption/docs:

- `examples/range_sampling.zig` prints a `rangeAtMostBatchChecked i16 [-50,50]`
  row;
- `tools/examplecheck.zig` guards the range example token;
- `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, and
  `README.md` list the new APIs;
- `compare/results/linux-no-known-gaps-audit.md` includes S4-M100 evidence.

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

- checked/unchecked `fillRangeAtMost` stream-shape parity;
- checked/unchecked `rangeAtMostBatch` stream-shape parity;
- zero-count checked batches returning before validation/allocation;
- invalid positive-count ranges returning before allocation or stream
  consumption;
- allocation-failure paths without stream consumption;
- degenerate `min == max` fill and owned batches not consuming randomness.

## S4-M100 Decision

S4-M100 is closed for the current inclusive integer range fill/owned batch bar:
callers can now fill caller-owned integer buffers or request owned inclusive
integer range slices directly.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
