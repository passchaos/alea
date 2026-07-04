# S4-M90 Rng Owned Normal and Exponential Batches

Date: 2026-07-04

Purpose: add allocation-returning normal and exponential sample batches for
`Rng`. This complements caller-owned `fillNormal` / `fillExponential`, checked
fill helpers, and the recent owned `Rng` batch APIs.

## Change

Added owned normal helpers in `src/rng.zig`:

- `Rng.normalBatch(T, allocator, count, mean, stddev)`;
- `Rng.normalBatchFrom(source, T, allocator, count, mean, stddev)`;
- `Rng.normalBatchChecked(T, allocator, count, mean, stddev)`;
- `Rng.normalBatchCheckedFrom(source, T, allocator, count, mean, stddev)`.

Added owned exponential helpers in `src/rng.zig`:

- `Rng.exponentialBatch(T, allocator, count, rate)`;
- `Rng.exponentialBatchFrom(source, T, allocator, count, rate)`;
- `Rng.exponentialBatchChecked(T, allocator, count, rate)`;
- `Rng.exponentialBatchCheckedFrom(source, T, allocator, count, rate)`.

The checked helpers preserve no-consume validation policy: zero-count requests
allocate an empty slice before validating parameters, invalid positive-count
requests return before allocating or drawing, allocation failures happen before
stream consumption, and degenerate `stddev == 0` / `rate == inf` paths fill
deterministically without consuming randomness.

Updated adoption/docs:

- `examples/basic.zig` prints `normalBatch` and `exponentialBatch` rows;
- `docs/examples.md` describes owned distribution batches in the basic example;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions normal/exponential batches;
- `tools/examplecheck.zig` guards the basic example tokens;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M90 evidence.

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

- checked/unchecked normal and exponential batch stream-shape parity for valid
  parameters;
- zero-count checked batches returning before invalid parameter validation or
  allocation failure;
- invalid positive-count normal/exponential parameters returning before
  allocation or stream consumption;
- allocation-failure paths without stream consumption;
- deterministic `stddev == 0` and `rate == inf` batches not consuming
  randomness.

## S4-M90 Decision

S4-M90 is closed for the current `Rng` owned normal/exponential batch bar:
callers can now request owned normal or exponential slices without manually
allocating and calling `fillNormal` / `fillExponential` themselves.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
