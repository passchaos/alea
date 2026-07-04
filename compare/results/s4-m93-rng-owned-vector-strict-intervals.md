# S4-M93 Rng Owned Vector Strict-Interval Batches

Date: 2026-07-04

Purpose: add allocation-returning vector strict-open and open-closed float
batches for `Rng`. This complements scalar `vectorOpen` / `vectorOpenClosed`,
caller-owned `fillVectorOpen` / `fillVectorOpenClosed`, and S4-M92 owned vector
range batches.

## Change

Added owned vector strict-interval helpers in `src/rng.zig`:

- `Rng.vectorOpenBatch(VectorType, allocator, count)`;
- `Rng.vectorOpenBatchFrom(source, VectorType, allocator, count)`;
- `Rng.vectorOpenClosedBatch(VectorType, allocator, count)`;
- `Rng.vectorOpenClosedBatchFrom(source, VectorType, allocator, count)`.

The helpers allocate before filling, so allocation failures and zero-length
requests do not consume randomness. They reuse the same strict endpoint policies
as `fillVectorOpen*` and `fillVectorOpenClosed*`.

Updated adoption/docs:

- `examples/range_sampling.zig` prints `vectorOpenBatch f32x4` and
  `vectorOpenClosedBatch f32x4` rows;
- `docs/examples.md` describes owned vector strict-interval batches in the range
  example;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions vector strict-interval batches;
- `tools/examplecheck.zig` guards the range example tokens;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M93 evidence.

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

- facade/direct stream-shape parity against `fillVectorOpen` /
  `fillVectorOpenClosed` for owned vector batches;
- output bounds for strict-open `(0, 1)` and open-closed `(0, 1]` vector lanes;
- allocation-failure paths without stream consumption;
- zero-length owned vector strict-interval batches returning before allocation
  failure or stream consumption.

## S4-M93 Decision

S4-M93 is closed for the current `Rng` owned vector strict-interval batch bar:
callers can now request owned vector strict-open or open-closed slices without
manually allocating and calling `fillVectorOpen` / `fillVectorOpenClosed`
themselves.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
