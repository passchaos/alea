# S4-M87 Rng Owned Range Batches

Date: 2026-07-04

Purpose: add allocation-returning scalar integer/float range batches for `Rng`.
This complements caller-owned `fillRange`, checked range fills, reusable
`Uniform(T).fill`, and S4-M85 owned value/sample batches.

## Change

Added owned range helpers in `src/rng.zig`:

- `Rng.rangeBatch(T, allocator, count, min, max)`;
- `Rng.rangeBatchFrom(source, T, allocator, count, min, max)`;
- `Rng.rangeBatchChecked(T, allocator, count, min, max)`;
- `Rng.rangeBatchCheckedFrom(source, T, allocator, count, min, max)`.

The checked helpers preserve existing no-consume validation policy:
zero-count requests allocate an empty slice before validating parameters,
positive-count invalid ranges return `EmptyRange` before allocating or drawing,
and allocation failures happen before stream consumption.

Updated adoption/docs:

- `examples/range_sampling.zig` prints `rangeBatch u16` and
  `rangeBatchChecked f64` rows;
- `docs/examples.md` describes owned range batches in the range example;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions `Rng.rangeBatch`;
- `tools/examplecheck.zig` guards the range example tokens;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M87 evidence.

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

- checked/unchecked range-batch stream-shape parity for valid ranges;
- zero-count checked batches returning before invalid parameter validation or
  allocation failure;
- invalid positive-count ranges returning before allocation or stream
  consumption;
- allocation-failure paths without stream consumption;
- degenerate one-value integer and collapsed floating-point range batches not
  consuming randomness.

## S4-M87 Decision

S4-M87 is closed for the current `Rng` owned range-batch bar: callers can now
request owned scalar range samples without manually allocating and calling
`fillRange`/`fillRangeChecked` themselves.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
