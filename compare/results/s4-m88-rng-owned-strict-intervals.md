# S4-M88 Rng Owned Strict-Interval Batches

Date: 2026-07-04

Purpose: add allocation-returning strict-open and open-closed float batches for
`Rng`. This complements caller-owned `fillOpen` / `fillOpenClosed`, reusable
`Open01` / `OpenClosed01` samplers, and S4-M87 owned range batches.

## Change

Added owned strict-interval helpers in `src/rng.zig`:

- `Rng.openBatch(T, allocator, count)`;
- `Rng.openBatchFrom(source, T, allocator, count)`;
- `Rng.openClosedBatch(T, allocator, count)`;
- `Rng.openClosedBatchFrom(source, T, allocator, count)`.

The helpers allocate before filling, so allocation failures and zero-length
requests do not consume randomness. They reuse the same strict endpoint policies
as `fillOpen*` and `fillOpenClosed*`.

Updated adoption/docs:

- `examples/range_sampling.zig` prints `openBatch f32` and
  `openClosedBatch f32` rows;
- `docs/examples.md` describes owned strict-interval batches in the range
  example;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions strict-interval `openBatch` / `openClosedBatch`;
- `tools/examplecheck.zig` guards the range example tokens;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M88 evidence.

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

- facade/direct stream-shape parity against `fillOpen` / `fillOpenClosed` for
  owned batches;
- output bounds for strict-open `(0, 1)` and open-closed `(0, 1]` batches;
- allocation-failure paths without stream consumption;
- zero-length owned strict-interval batches returning before allocation failure
  or stream consumption.

## S4-M88 Decision

S4-M88 is closed for the current `Rng` owned strict-interval batch bar: callers
can now request owned strict-open or open-closed float slices without manually
allocating and calling `fillOpen` / `fillOpenClosed` themselves.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
