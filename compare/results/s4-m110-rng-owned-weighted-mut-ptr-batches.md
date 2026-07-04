# S4-M110 Rng Repeated Weighted Mutable-Pointer Batches

Date: 2026-07-04

Purpose: add caller-owned and allocation-returning repeated f64 weighted
mutable-pointer choice helpers for `Rng`. This complements
`Rng.chooseWeightedConstPtrBatch`, `seq.chooseWeightedPtr`, reusable weighted
choice pointer workflows, no-copy mutable draws, and Rust `choose_weighted_mut`
loops.

## Rust rand Comparison

Rust slice weighted selection exposes `choose_weighted_mut` for a mutable
reference and users repeat that call in loops when they need repeated mutable
weighted draws. Alea already had generic one-shot weighted mutable pointers in
`seq`, direct `Rng` repeated weighted values and const pointers, and weighted
no-replacement mutable-pointer helpers; S4-M110 adds direct `Rng` f64-weighted
mutable-pointer fill and owned-batch helpers for simple repeated mutable item
workflows without copying values.

## Change

Added repeated weighted mutable-pointer helpers in `src/rng.zig`:

- `Rng.chooseWeightedPtr(T, items, weights)` returning `?*T`;
- `Rng.chooseWeightedPtrFrom(source, T, items, weights)`;
- `Rng.fillChooseWeightedPtr(T, dest, items, weights)` for optional `?*T`
  outputs;
- `Rng.fillChooseWeightedPtrFrom(source, T, dest, items, weights)`;
- `Rng.chooseWeightedPtrBatch(T, allocator, count, items, weights)` returning
  `[]?*T`;
- `Rng.chooseWeightedPtrBatchFrom(source, T, allocator, count, items, weights)`;
- `Rng.chooseWeightedPtrChecked(T, items, weights)` returning `*T`;
- `Rng.chooseWeightedPtrCheckedFrom(source, T, items, weights)`;
- `Rng.fillChooseWeightedPtrChecked(T, dest, items, weights)` for non-null
  `*T` outputs;
- `Rng.fillChooseWeightedPtrCheckedFrom(source, T, dest, items, weights)`;
- `Rng.chooseWeightedPtrBatchChecked(T, allocator, count, items, weights)`
  returning `[]*T`;
- `Rng.chooseWeightedPtrBatchCheckedFrom(source, T, allocator, count, items,
  weights)`.

The checked helpers validate item/weight length and weights before drawing or
allocating for positive counts, return zero-count slices before validation,
reject empty/all-zero weights as `EmptyRange` for non-null checked output, and
preserve single-positive and allocation-failure no-consume behavior. Optional
helpers return null pointers for empty/all-zero weights and use `?*T` batches for
fallible input workflows.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints a `weighted mut ptr batch scores` row;
- `tools/examplecheck.zig` guards the example token;
- `docs/core-guide.md`, `docs/api-reference.md`, and `docs/examples.md` list
  the new direct `Rng` weighted mutable-pointer batch workflow;
- `compare/results/linux-no-known-gaps-audit.md` includes S4-M110 evidence.

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

- checked/unchecked repeated weighted-mutable-pointer stream-shape parity;
- optional `[]?*T` and checked `[]*T` output shapes;
- single-positive no-consume behavior;
- zero-length checked fills and zero-count checked batches returning before
  validation;
- invalid/non-finite weights, all-zero weights, length mismatch, and
  allocation-failure paths returning before stream consumption where validation
  can happen first.

## S4-M110 Decision

S4-M110 is closed for the current repeated f64 weighted mutable-pointer batch
bar: callers can now fill caller-owned weighted mutable-pointer buffers or
request owned repeated weighted mutable-pointer slices directly from `Rng`.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
