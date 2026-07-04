# S4-M89 Rng Owned Probability Batches

Date: 2026-07-04

Purpose: add allocation-returning boolean probability batches for `Rng`. This
complements scalar `chance` / `ratio`, caller-owned `fillChance` / `fillRatio`,
vector probability helpers, and the packed boolean fill policies.

## Change

Added owned probability helpers in `src/rng.zig`:

- `Rng.chanceBatch(allocator, count, p)`;
- `Rng.chanceBatchFrom(source, allocator, count, p)`;
- `Rng.chanceBatchChecked(allocator, count, p)`;
- `Rng.chanceBatchCheckedFrom(source, allocator, count, p)`;
- `Rng.ratioBatch(allocator, count, numerator, denominator)`;
- `Rng.ratioBatchFrom(source, allocator, count, numerator, denominator)`;
- `Rng.ratioBatchChecked(allocator, count, numerator, denominator)`;
- `Rng.ratioBatchCheckedFrom(source, allocator, count, numerator, denominator)`.

The checked helpers preserve no-consume validation policy: zero-count requests
allocate an empty slice before validating probability/ratio parameters, invalid
positive-count requests return before allocating or drawing, allocation failures
happen before stream consumption, and degenerate p=0/p=1 or ratio=0/1 paths fill
deterministically without consuming randomness.

Updated adoption/docs:

- `examples/basic.zig` prints `chanceBatch p=.25` and `ratioBatch 3/8` rows;
- `docs/examples.md` describes owned probability batches in the basic example;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions probability `chanceBatch` / `ratioBatch`;
- `tools/examplecheck.zig` guards the basic example tokens;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M89 evidence.

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

- checked/unchecked chance and ratio batch stream-shape parity for valid
  parameters;
- zero-count checked batches returning before invalid parameter validation or
  allocation failure;
- invalid positive-count probabilities/ratios returning before allocation or
  stream consumption;
- allocation-failure paths without stream consumption;
- deterministic p=0/p=1 and ratio=0/1 batches not consuming randomness.

## S4-M89 Decision

S4-M89 is closed for the current `Rng` owned probability-batch bar: callers can
now request owned chance/ratio boolean slices without manually allocating and
calling `fillChance` / `fillRatio` themselves.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
