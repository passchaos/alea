# S4-M92 Rng Owned Vector Range Batches

Date: 2026-07-04

Purpose: add allocation-returning vector range batches for `Rng`. This
complements scalar `vectorRange`, caller-owned `fillVectorRange`, checked vector
range helpers, and S4-M87 scalar owned range batches.

## Change

Added owned vector range helpers in `src/rng.zig`:

- `Rng.vectorRangeBatch(VectorType, allocator, count, min, max)`;
- `Rng.vectorRangeBatchFrom(source, VectorType, allocator, count, min, max)`;
- `Rng.vectorRangeBatchChecked(VectorType, allocator, count, min, max)`;
- `Rng.vectorRangeBatchCheckedFrom(source, VectorType, allocator, count, min, max)`.

The checked helpers preserve no-consume validation policy: zero-count requests
allocate an empty slice before validating bounds, invalid positive-count
requests return before allocating or drawing, allocation failures happen before
stream consumption, and degenerate one-value integer / collapsed floating-point
vector ranges fill deterministically without consuming randomness.

Updated adoption/docs:

- `examples/range_sampling.zig` prints a `vectorRangeBatch f32x4` row;
- `docs/examples.md` describes owned vector-range batches in the range example;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions duration/vector range batches;
- `tools/examplecheck.zig` guards the range example token;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M92 evidence.

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

- checked/unchecked vector range batch stream-shape parity for valid ranges;
- zero-count checked batches returning before invalid bound validation or
  allocation failure;
- invalid positive-count vector ranges returning before allocation or stream
  consumption;
- allocation-failure paths without stream consumption;
- degenerate one-value integer and collapsed floating-point vector batches not
  consuming randomness.

## S4-M92 Decision

S4-M92 is closed for the current `Rng` owned vector range-batch bar: callers can
now request owned vector range samples without manually allocating and calling
`fillVectorRange` / `fillVectorRangeChecked` themselves.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
