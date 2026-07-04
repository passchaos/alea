# S4-M95 Rng Owned Vector Normal and Exponential Batches

Date: 2026-07-04

Purpose: add allocation-returning vector normal/exponential batches for `Rng`.
This complements scalar `vectorNormal` / `vectorExponential`, caller-owned
`fillVectorNormal` / `fillVectorExponential`, S4-M90 scalar owned
normal/exponential batches, and the S4-M92 through S4-M94 owned vector batch
families.

## Rust rand Comparison

The local Rust `rand` / `rand_distr` baseline provides scalar distribution
samplers and iterator-based repeated draws, but it does not expose a Zig-native
owned `[]@Vector(N, f32/f64)` batch API. Alea now keeps the Rust-equivalent
scalar/repeated workflows and adds a direct owned vector-lane workflow, avoiding
manual allocation plus `fillVectorNormal` / `fillVectorExponential` ceremony for
users who batch vector samples.

This is intentionally not a Rust trait/API port: the API follows Alea's existing
Zig `Rng.*Batch` pattern, takes an allocator explicitly, and preserves the same
checked no-consume behavior used by scalar and other vector owned batches.

## Change

Added owned vector normal helpers in `src/rng.zig`:

- `Rng.vectorNormalBatch(VectorType, allocator, count, mean, stddev)`;
- `Rng.vectorNormalBatchFrom(source, VectorType, allocator, count, mean, stddev)`;
- `Rng.vectorNormalBatchChecked(VectorType, allocator, count, mean, stddev)`;
- `Rng.vectorNormalBatchCheckedFrom(source, VectorType, allocator, count, mean, stddev)`.

Added owned vector exponential helpers in `src/rng.zig`:

- `Rng.vectorExponentialBatch(VectorType, allocator, count, rate)`;
- `Rng.vectorExponentialBatchFrom(source, VectorType, allocator, count, rate)`;
- `Rng.vectorExponentialBatchChecked(VectorType, allocator, count, rate)`;
- `Rng.vectorExponentialBatchCheckedFrom(source, VectorType, allocator, count, rate)`.

The checked helpers preserve no-consume validation policy: zero-count requests
allocate an empty slice before validating normal/exponential parameters, invalid
positive-count requests return before allocating or drawing, allocation failures
happen before stream consumption, and degenerate `stddev == 0` / `rate == inf`
paths fill deterministically without consuming randomness.

Updated adoption/docs:

- `examples/basic.zig` prints `vectorNormalBatch f64x4` and
  `vectorExponentialBatch f64x4` rows;
- `docs/examples.md` describes scalar-and-vector normal/exponential batches in
  the basic example;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions scalar/vector normal/exponential batches;
- `tools/examplecheck.zig` guards the basic example tokens;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M95 evidence.

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

- checked/unchecked vector normal and vector exponential batch stream-shape
  parity for valid parameters;
- zero-count checked batches returning before invalid parameter validation or
  allocation failure;
- invalid positive-count vector normal/exponential parameters returning before
  allocation or stream consumption;
- allocation-failure paths without stream consumption;
- deterministic `stddev == 0` and `rate == inf` vector batches not consuming
  randomness.

## S4-M95 Decision

S4-M95 is closed for the current `Rng` owned vector normal/exponential batch
bar: callers can now request owned vector normal or exponential slices without
manually allocating and calling `fillVectorNormal` / `fillVectorExponential`
themselves.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
