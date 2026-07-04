# S4-M109 Rng Repeated Weighted Const-Pointer Batches

Date: 2026-07-04

Purpose: add caller-owned and allocation-returning repeated f64 weighted
const-pointer choice helpers for `Rng`. This complements `Rng.chooseWeighted`,
`seq.chooseWeightedConstPtr`, reusable `WeightedChoice.ptrs*` batches, no-copy
immutable workflows, and Rust `choose_weighted_iter` repeated reference draws.

## Rust rand Comparison

Rust slice weighted selection exposes `choose_weighted` for one reference and
`choose_weighted_iter` for repeated with-replacement references. Alea already
had generic one-shot weighted const pointers in `seq` and reusable
`WeightedChoice.ptrs*`; S4-M109 adds direct `Rng` f64-weighted const-pointer
fill and owned-batch helpers for simple repeated immutable item draws without
copying values or building a reusable alias table.

## Change

Added repeated weighted const-pointer helpers in `src/rng.zig`:

- `Rng.chooseWeightedConstPtr(T, items, weights)` returning `?*const T`;
- `Rng.chooseWeightedConstPtrFrom(source, T, items, weights)`;
- `Rng.fillChooseWeightedConstPtr(T, dest, items, weights)` for optional
  `?*const T` outputs;
- `Rng.fillChooseWeightedConstPtrFrom(source, T, dest, items, weights)`;
- `Rng.chooseWeightedConstPtrBatch(T, allocator, count, items, weights)`
  returning `[]?*const T`;
- `Rng.chooseWeightedConstPtrBatchFrom(source, T, allocator, count, items,
  weights)`;
- `Rng.chooseWeightedConstPtrChecked(T, items, weights)` returning `*const T`;
- `Rng.chooseWeightedConstPtrCheckedFrom(source, T, items, weights)`;
- `Rng.fillChooseWeightedConstPtrChecked(T, dest, items, weights)` for
  non-null `*const T` outputs;
- `Rng.fillChooseWeightedConstPtrCheckedFrom(source, T, dest, items, weights)`;
- `Rng.chooseWeightedConstPtrBatchChecked(T, allocator, count, items, weights)`
  returning `[]*const T`;
- `Rng.chooseWeightedConstPtrBatchCheckedFrom(source, T, allocator, count,
  items, weights)`.

The checked helpers validate item/weight length and weights before drawing or
allocating for positive counts, return zero-count slices before validation,
reject empty/all-zero weights as `EmptyRange` for non-null checked output, and
preserve single-positive and allocation-failure no-consume behavior. Optional
helpers return null pointers for empty/all-zero weights and use `?*const T`
batches for fallible input workflows.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints a `weighted const ptr batch` row;
- `tools/examplecheck.zig` guards the example token;
- `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, and
  `README.md` list the new direct `Rng` weighted const-pointer batch workflow;
- `compare/results/linux-no-known-gaps-audit.md` includes S4-M109 evidence.

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

- checked/unchecked repeated weighted-const-pointer stream-shape parity;
- optional `[]?*const T` and checked `[]*const T` output shapes;
- single-positive no-consume behavior;
- zero-length checked fills and zero-count checked batches returning before
  validation;
- invalid/non-finite weights, all-zero weights, length mismatch, and
  allocation-failure paths returning before stream consumption where validation
  can happen first.

## S4-M109 Decision

S4-M109 is closed for the current repeated f64 weighted const-pointer batch bar:
callers can now fill caller-owned weighted const-pointer buffers or request
owned repeated weighted const-pointer slices directly from `Rng`.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
