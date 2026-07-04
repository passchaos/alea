# S4-M91 Rng Owned Duration Range Batches

Date: 2026-07-04

Purpose: add allocation-returning `std.Io.Duration` range batches for `Rng`.
This complements scalar `durationRangeLessThan` / `durationRangeAtMost` and their
checked/direct-source variants.

## Change

Added owned duration less-than helpers in `src/rng.zig`:

- `Rng.durationRangeLessThanBatch(allocator, count, min, max)`;
- `Rng.durationRangeLessThanBatchFrom(source, allocator, count, min, max)`;
- `Rng.durationRangeLessThanBatchChecked(allocator, count, min, max)`;
- `Rng.durationRangeLessThanBatchCheckedFrom(source, allocator, count, min, max)`.

Added owned duration at-most helpers in `src/rng.zig`:

- `Rng.durationRangeAtMostBatch(allocator, count, min, max)`;
- `Rng.durationRangeAtMostBatchFrom(source, allocator, count, min, max)`;
- `Rng.durationRangeAtMostBatchChecked(allocator, count, min, max)`;
- `Rng.durationRangeAtMostBatchCheckedFrom(source, allocator, count, min, max)`.

The checked helpers preserve no-consume validation policy: zero-count requests
allocate an empty slice before validating bounds, invalid positive-count requests
return before allocating or drawing, allocation failures happen before stream
consumption, and degenerate at-most ranges fill deterministically without
consuming randomness.

Updated adoption/docs:

- `examples/range_sampling.zig` prints a `durationRangeAtMostBatch` row;
- `docs/examples.md` describes owned duration/range batches in the range example;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions duration range batches;
- `tools/examplecheck.zig` guards the range example token;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M91 evidence.

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

- checked/unchecked duration batch stream-shape parity for valid less-than and
  at-most ranges;
- zero-count checked batches returning before invalid bound validation or
  allocation failure;
- invalid positive-count duration ranges returning before allocation or stream
  consumption;
- allocation-failure paths without stream consumption;
- degenerate at-most duration batches not consuming randomness.

## S4-M91 Decision

S4-M91 is closed for the current `Rng` owned duration range-batch bar: callers
can now request owned `std.Io.Duration` range samples without manually allocating
and looping over scalar duration range helpers.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
