# S4-M106 Rng Repeated Weighted Index Batches

Date: 2026-07-04

Purpose: add caller-owned and allocation-returning repeated f64 weighted index
helpers for `Rng`. This complements one-shot `Rng.weightedIndex`, compact
`weightedIndexU32`, reusable weighted choice batches, and local Rust repeated
weighted index loops.

## Rust rand Comparison

Rust weighted index APIs are typically sampled repeatedly through loops or
reusable distributions. Alea already had one-shot f64 weighted index helpers,
generic weighted index helpers in `seq`, and reusable `WeightedChoice` batches;
S4-M106 adds direct `Rng` caller-owned and owned repeated f64 weighted index
helpers for simple repeated draws.

## Change

Added repeated weighted index helpers in `src/rng.zig`:

- `Rng.fillWeightedIndex(dest, weights)` for optional `?usize` outputs;
- `Rng.fillWeightedIndexFrom(source, dest, weights)`;
- `Rng.weightedIndexBatch(allocator, count, weights)` returning `[]?usize`;
- `Rng.weightedIndexBatchFrom(source, allocator, count, weights)`;
- `Rng.fillWeightedIndexChecked(dest, weights)` for non-null `usize` outputs;
- `Rng.fillWeightedIndexCheckedFrom(source, dest, weights)`;
- `Rng.weightedIndexBatchChecked(allocator, count, weights)` returning `[]usize`;
- `Rng.weightedIndexBatchCheckedFrom(source, allocator, count, weights)`.

The checked helpers validate weights before drawing or allocating for positive
counts, return zero-count slices before validation, reject empty/all-zero weights
as `EmptyRange` for non-optional checked output, and preserve single-positive
and allocation-failure no-consume behavior.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints a `weighted index batch` row;
- `tools/examplecheck.zig` guards the example token;
- `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, and
  `README.md` list the new APIs;
- `compare/results/linux-no-known-gaps-audit.md` includes S4-M106 evidence.

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

- checked/unchecked repeated weighted-index stream-shape parity;
- optional `[]?usize` and checked `[]usize` output shapes;
- single-positive no-consume behavior;
- zero-length checked fills and zero-count checked batches returning before
  validation;
- invalid/non-finite weights, all-zero weights, and allocation-failure paths
  returning before stream consumption where validation can happen first.

## S4-M106 Decision

S4-M106 is closed for the current repeated f64 weighted index batch bar: callers
can now fill caller-owned weighted-index buffers or request owned repeated
weighted-index slices directly from `Rng`.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
