# S4-M94 Rng Owned Vector Probability Batches

Date: 2026-07-04

Purpose: add allocation-returning vector boolean probability batches for `Rng`.
This complements scalar `vectorChance` / `vectorRatio`, caller-owned
`fillVectorChance` / `fillVectorRatio`, and S4-M89 scalar owned probability
batches.

## Change

Added owned vector chance helpers in `src/rng.zig`:

- `Rng.vectorChanceBatch(VectorType, allocator, count, p)`;
- `Rng.vectorChanceBatchFrom(source, VectorType, allocator, count, p)`;
- `Rng.vectorChanceBatchChecked(VectorType, allocator, count, p)`;
- `Rng.vectorChanceBatchCheckedFrom(source, VectorType, allocator, count, p)`.

Added owned vector ratio helpers in `src/rng.zig`:

- `Rng.vectorRatioBatch(VectorType, allocator, count, numerator, denominator)`;
- `Rng.vectorRatioBatchFrom(source, VectorType, allocator, count, numerator, denominator)`;
- `Rng.vectorRatioBatchChecked(VectorType, allocator, count, numerator, denominator)`;
- `Rng.vectorRatioBatchCheckedFrom(source, VectorType, allocator, count, numerator, denominator)`.

The checked helpers preserve no-consume validation policy: zero-count requests
allocate an empty slice before validating probability/ratio parameters, invalid
positive-count requests return before allocating or drawing, allocation failures
happen before stream consumption, and degenerate p=0/p=1 or ratio=0/1 paths fill
deterministically without consuming randomness.

Updated adoption/docs:

- `examples/basic.zig` prints `vectorChanceBatch boolx8` and
  `vectorRatioBatch boolx8` rows;
- `docs/examples.md` describes owned scalar/vector probability batches in the
  basic example;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions vector probability batches;
- `tools/examplecheck.zig` guards the basic example tokens;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M94 evidence.

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

- checked/unchecked vector chance and vector ratio batch stream-shape parity for
  valid parameters;
- zero-count checked batches returning before invalid parameter validation or
  allocation failure;
- invalid positive-count vector probabilities/ratios returning before allocation
  or stream consumption;
- allocation-failure paths without stream consumption;
- deterministic p=0/p=1 and ratio=0/1 vector batches not consuming randomness.

## S4-M94 Decision

S4-M94 is closed for the current `Rng` owned vector probability-batch bar:
callers can now request owned vector chance/ratio boolean slices without manually
allocating and calling `fillVectorChance` / `fillVectorRatio` themselves.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
