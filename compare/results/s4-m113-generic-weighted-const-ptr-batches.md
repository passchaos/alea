# S4-M113 Generic Repeated Weighted Const-Pointer Batches

Date: 2026-07-04

Purpose: add caller-owned and allocation-returning repeated generic-weight
weighted const-pointer helpers in `seq`. This complements one-shot
`seq.chooseWeightedConstPtr`, S4-M112 generic weighted value batches,
f64-specific `Rng.chooseWeightedConstPtrBatch`, reusable `WeightedChoice.ptrs*`,
no-copy immutable workflows, and local Rust `choose_weighted_iter` reference
loops over integer or float weights.

## Rust rand Comparison

Rust slice weighted reference workflows accept integer or float weight types
through `choose_weighted` / `WeightedIndex` and are repeated through loops or
iterators. Alea already had generic one-shot weighted const pointers in `seq`
and f64 repeated weighted const-pointer batches in `Rng`; S4-M113 adds direct
generic-weight repeated with-replacement const-pointer fills and owned batches.

## Change

Added generic repeated weighted const-pointer helpers in `src/seq.zig`:

- `seq.fillChooseWeightedConstPtr(T, Weight, dest, items, weights)` for optional
  `?*const T` output;
- `seq.fillChooseWeightedConstPtrFrom(source, T, Weight, dest, items, weights)`;
- `seq.fillChooseWeightedConstPtrChecked(T, Weight, dest, items, weights)` for
  non-null `*const T` output;
- `seq.fillChooseWeightedConstPtrCheckedFrom(source, T, Weight, dest, items,
  weights)`;
- `seq.chooseWeightedConstPtrBatch(allocator, rng, T, Weight, count, items,
  weights)` returning `[]?*const T`;
- `seq.chooseWeightedConstPtrBatchFrom(allocator, source, T, Weight, count,
  items, weights)`;
- `seq.chooseWeightedConstPtrBatchChecked(allocator, rng, T, Weight, count,
  items, weights)` returning `[]*const T`;
- `seq.chooseWeightedConstPtrBatchCheckedFrom(allocator, source, T, Weight,
  count, items, weights)`.

The implementation reuses generic weighted-index prevalidation so repeated
helpers validate once, then sample with a precomputed total. Checked helpers
reject empty/all-zero weights as `EmptyInput`, reject length mismatch and
invalid/non-finite weights before drawing or allocation for positive counts,
preserve zero-count/zero-length no-op behavior, and preserve single-positive and
allocation-failure no-consume behavior.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints a `generic weighted const ptr batch`
  row;
- `tools/examplecheck.zig` guards the example token;
- `docs/core-guide.md`, `docs/examples.md`, and `README.md` mention the generic
  repeated weighted const-pointer workflow;
- `compare/results/linux-no-known-gaps-audit.md` includes S4-M113 evidence.

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

- repeated generic weighted const-pointer fill and owned batch selection;
- checked/unchecked stream-shape parity for repeated generic weighted const
  pointers;
- single-positive no-consume behavior;
- optional all-zero output, zero-length checked fills, and zero-count checked
  batches returning before validation;
- length mismatch, invalid/non-finite weights, all-zero checked weights, and
  allocation-failure paths returning before stream consumption where validation
  can happen first.

## S4-M113 Decision

S4-M113 is closed for the current generic repeated weighted const-pointer batch
bar: callers can now fill caller-owned weighted const-pointer buffers or request
owned repeated weighted const-pointer slices for integer or float weights through
`seq`.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
