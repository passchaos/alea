# S4-M114 Generic Repeated Weighted Mutable-Pointer Batches

Date: 2026-07-04

Purpose: add caller-owned and allocation-returning repeated generic-weight
weighted mutable-pointer helpers in `seq`. This complements one-shot
`seq.chooseWeightedPtr`, S4-M113 generic weighted const-pointer batches,
f64-specific `Rng.chooseWeightedPtrBatch`, no-copy mutable workflows, and local
Rust `choose_weighted_mut` loops over integer or float weights.

## Rust rand Comparison

Rust slice weighted mutable-reference workflows accept integer or float weight
types through `choose_weighted_mut` / `WeightedIndex` and are repeated through
loops when callers mutate selected items. Alea already had generic one-shot
weighted mutable pointers in `seq` and f64 repeated weighted mutable-pointer
batches in `Rng`; S4-M114 adds direct generic-weight repeated with-replacement
mutable-pointer fills and owned batches.

## Change

Added generic repeated weighted mutable-pointer helpers in `src/seq.zig`:

- `seq.fillChooseWeightedPtr(T, Weight, dest, items, weights)` for optional
  `?*T` output;
- `seq.fillChooseWeightedPtrFrom(source, T, Weight, dest, items, weights)`;
- `seq.fillChooseWeightedPtrChecked(T, Weight, dest, items, weights)` for
  non-null `*T` output;
- `seq.fillChooseWeightedPtrCheckedFrom(source, T, Weight, dest, items,
  weights)`;
- `seq.chooseWeightedPtrBatch(allocator, rng, T, Weight, count, items, weights)`
  returning `[]?*T`;
- `seq.chooseWeightedPtrBatchFrom(allocator, source, T, Weight, count, items,
  weights)`;
- `seq.chooseWeightedPtrBatchChecked(allocator, rng, T, Weight, count, items,
  weights)` returning `[]*T`;
- `seq.chooseWeightedPtrBatchCheckedFrom(allocator, source, T, Weight, count,
  items, weights)`.

The implementation reuses generic weighted-index prevalidation so repeated
helpers validate once, then sample with a precomputed total. Checked helpers
reject empty/all-zero weights as `EmptyInput`, reject length mismatch and
invalid/non-finite weights before drawing or allocation for positive counts,
preserve zero-count/zero-length no-op behavior, and preserve single-positive and
allocation-failure no-consume behavior.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints a `generic weighted mut ptr batch
  scores` row;
- `tools/examplecheck.zig` guards the example token;
- `docs/core-guide.md`, `docs/examples.md`, and `README.md` mention the generic
  repeated weighted mutable-pointer workflow;
- `compare/results/linux-no-known-gaps-audit.md` includes S4-M114 evidence.

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

- repeated generic weighted mutable-pointer fill and owned batch selection;
- checked/unchecked stream-shape parity for repeated generic weighted mutable
  pointers;
- single-positive no-consume behavior;
- optional all-zero output, zero-length checked fills, and zero-count checked
  batches returning before validation;
- length mismatch, invalid/non-finite weights, all-zero checked weights, and
  allocation-failure paths returning before stream consumption where validation
  can happen first.

## S4-M114 Decision

S4-M114 is closed for the current generic repeated weighted mutable-pointer batch
bar: callers can now fill caller-owned weighted mutable-pointer buffers or
request owned repeated weighted mutable-pointer slices for integer or float
weights through `seq`.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
