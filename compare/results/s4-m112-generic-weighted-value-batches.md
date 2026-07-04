# S4-M112 Generic Repeated Weighted Value Batches

Date: 2026-07-04

Purpose: add caller-owned and allocation-returning repeated generic-weight
weighted value helpers in `seq`. This complements one-shot `seq.chooseWeighted`,
S4-M111 generic weighted index batches, f64-specific `Rng.chooseWeightedBatch`,
reusable `WeightedChoice.values*`, and local Rust `choose_weighted_iter` loops
over integer or float weights.

## Rust rand Comparison

Rust slice weighted value workflows accept integer or float weight types through
`choose_weighted` / `WeightedIndex` and are repeated through loops or iterators.
Alea already had generic one-shot weighted values in `seq` and f64 repeated
weighted value batches in `Rng`; S4-M112 adds direct generic-weight repeated
with-replacement value fills and owned batches.

## Change

Added generic repeated weighted value helpers in `src/seq.zig`:

- `seq.fillChooseWeighted(T, Weight, dest, items, weights)` for optional `?T`
  output;
- `seq.fillChooseWeightedFrom(source, T, Weight, dest, items, weights)`;
- `seq.fillChooseWeightedChecked(T, Weight, dest, items, weights)` for non-null
  `T` output;
- `seq.fillChooseWeightedCheckedFrom(source, T, Weight, dest, items, weights)`;
- `seq.chooseWeightedBatch(allocator, rng, T, Weight, count, items, weights)`
  returning `[]?T`;
- `seq.chooseWeightedBatchFrom(allocator, source, T, Weight, count, items,
  weights)`;
- `seq.chooseWeightedBatchChecked(allocator, rng, T, Weight, count, items,
  weights)` returning `[]T`;
- `seq.chooseWeightedBatchCheckedFrom(allocator, source, T, Weight, count,
  items, weights)`.

The implementation reuses generic weighted-index prevalidation so repeated
helpers validate once, then sample with a precomputed total. Checked helpers
reject empty/all-zero weights as `EmptyInput`, reject length mismatch and
invalid/non-finite weights before drawing or allocation for positive counts,
preserve zero-count/zero-length no-op behavior, and preserve single-positive and
allocation-failure no-consume behavior.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints a `generic weighted value batch` row;
- `tools/examplecheck.zig` guards the example token;
- `docs/core-guide.md`, `docs/examples.md`, and `README.md` mention the generic
  repeated weighted value workflow;
- `compare/results/linux-no-known-gaps-audit.md` includes S4-M112 evidence.

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

- repeated generic weighted value fill and owned batch selection;
- checked/unchecked stream-shape parity for repeated generic weighted values;
- single-positive no-consume behavior;
- optional all-zero output, zero-length checked fills, and zero-count checked
  batches returning before validation;
- length mismatch, invalid/non-finite weights, all-zero checked weights, and
  allocation-failure paths returning before stream consumption where validation
  can happen first.

## S4-M112 Decision

S4-M112 is closed for the current generic repeated weighted value batch bar:
callers can now fill caller-owned weighted value buffers or request owned
repeated weighted value slices for integer or float weights through `seq`.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
