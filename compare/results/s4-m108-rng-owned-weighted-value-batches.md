# S4-M108 Rng Repeated Weighted Value Batches

Date: 2026-07-04

Purpose: add caller-owned and allocation-returning repeated f64 weighted value
choice helpers for `Rng`. This complements `Rng.weightedIndexBatch`, generic
weighted value choices, reusable weighted choice value batches, and local Rust
repeated weighted choice loops.

## Rust rand Comparison

Rust weighted value choices are typically sampled repeatedly through loops or a
reusable distribution. Alea already had one-shot generic weighted value helpers
in `seq`, repeated weighted index batches in `Rng`, and reusable
`WeightedChoice.values*`; S4-M108 adds direct `Rng` caller-owned and owned
repeated f64 weighted value helpers for simple repeated draws.

## Change

Added repeated weighted value helpers in `src/rng.zig`:

- `Rng.chooseWeighted(T, items, weights)` returning `?T`;
- `Rng.chooseWeightedFrom(source, T, items, weights)`;
- `Rng.fillChooseWeighted(T, dest, items, weights)` for optional `?T` outputs;
- `Rng.fillChooseWeightedFrom(source, T, dest, items, weights)`;
- `Rng.chooseWeightedBatch(T, allocator, count, items, weights)` returning `[]?T`;
- `Rng.chooseWeightedBatchFrom(source, T, allocator, count, items, weights)`;
- `Rng.fillChooseWeightedChecked(T, dest, items, weights)` for non-null `T` outputs;
- `Rng.fillChooseWeightedCheckedFrom(source, T, dest, items, weights)`;
- `Rng.chooseWeightedBatchChecked(T, allocator, count, items, weights)` returning `[]T`;
- `Rng.chooseWeightedBatchCheckedFrom(source, T, allocator, count, items, weights)`.

The checked helpers validate weight/item length and weights before drawing or
allocating for positive counts, return zero-count slices before validation,
reject empty/all-zero weights as `EmptyRange` for non-optional checked output,
and preserve single-positive and allocation-failure no-consume behavior.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints a `weighted value batch` row;
- `tools/examplecheck.zig` guards the example token;
- `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, and
  `README.md` list the new APIs;
- `compare/results/linux-no-known-gaps-audit.md` includes S4-M108 evidence.

## Validation

Commands for final validation:

```sh
git diff --check
zig build test
zig build run-weighted-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- checked/unchecked repeated weighted-value stream-shape parity;
- optional `[]?T` and checked `[]T` output shapes;
- single-positive no-consume behavior;
- zero-length checked fills and zero-count checked batches returning before
  validation;
- invalid/non-finite weights, all-zero weights, length mismatch, and
  allocation-failure paths returning before stream consumption where validation
  can happen first.

## S4-M108 Decision

S4-M108 is closed for the current repeated f64 weighted value batch bar: callers
can now fill caller-owned weighted-value buffers or request owned repeated
weighted-value slices directly from `Rng`.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
