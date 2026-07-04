# S4-M111 Generic Repeated Weighted Index Batches

Date: 2026-07-04

Purpose: add caller-owned and allocation-returning repeated generic-weight
usize/u32 weighted index helpers in `seq`. This complements one-shot
`seq.weightedIndex`, one-shot compact `seq.weightedIndexU32`, f64-specific
`Rng.weightedIndexBatch`, no-replacement weighted index batches, and local Rust
repeated weighted index loops over integer or float weights.

## Rust rand Comparison

Rust weighted index workflows support generic integer or float weights through
`WeightedIndex` and repeated sampling through loops or iterators. Alea already
had generic one-shot weighted indexes in `seq` and f64 repeated weighted index
batches in `Rng`; S4-M111 adds direct generic-weight repeated with-replacement
index fills and owned batches, including compact `u32` output.

## Change

Added generic repeated weighted index helpers in `src/seq.zig`:

- `seq.fillWeightedIndex(Weight, dest, weights)` for optional `?usize` output;
- `seq.fillWeightedIndexFrom(source, Weight, dest, weights)`;
- `seq.fillWeightedIndexChecked(Weight, dest, weights)` for non-null `usize` output;
- `seq.fillWeightedIndexCheckedFrom(source, Weight, dest, weights)`;
- `seq.weightedIndexBatch(allocator, rng, Weight, count, weights)` returning `[]?usize`;
- `seq.weightedIndexBatchFrom(allocator, source, Weight, count, weights)`;
- `seq.weightedIndexBatchChecked(allocator, rng, Weight, count, weights)` returning `[]usize`;
- `seq.weightedIndexBatchCheckedFrom(allocator, source, Weight, count, weights)`;
- `seq.fillWeightedIndexU32(Weight, dest, weights)` for optional `?u32` output;
- `seq.fillWeightedIndexU32From(source, Weight, dest, weights)`;
- `seq.fillWeightedIndexU32Checked(Weight, dest, weights)` for non-null `u32` output;
- `seq.fillWeightedIndexU32CheckedFrom(source, Weight, dest, weights)`;
- `seq.weightedIndexU32Batch(allocator, rng, Weight, count, weights)` returning `[]?u32`;
- `seq.weightedIndexU32BatchFrom(allocator, source, Weight, count, weights)`;
- `seq.weightedIndexU32BatchChecked(allocator, rng, Weight, count, weights)` returning `[]u32`;
- `seq.weightedIndexU32BatchCheckedFrom(allocator, source, Weight, count, weights)`.

The implementation factors generic weight validation/prevalidation so repeated
helpers validate once, then sample with a precomputed total. Checked helpers
reject empty/all-zero weights as `EmptyInput`, reject invalid/non-finite weights
before drawing or allocation for positive counts, preserve zero-count/zero-length
no-op behavior, preserve single-positive no-consume behavior, and keep compact
`u32` overflow checks before narrowing.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints `generic weighted index batch` and
  `generic weighted u32 index batch` rows;
- `tools/examplecheck.zig` guards the example tokens;
- `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, and
  `README.md` list the generic repeated weighted index batch workflow;
- `compare/results/linux-no-known-gaps-audit.md` includes S4-M111 evidence.

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

- repeated generic usize/u32 weighted fill and owned batch selection;
- checked/unchecked stream-shape parity for repeated generic usize/u32 indexes;
- single-positive no-consume behavior;
- optional all-zero output, zero-length checked fills, and zero-count checked
  batches returning before validation;
- invalid/non-finite weights, all-zero checked weights, and allocation-failure
  paths returning before stream consumption where validation can happen first.

## S4-M111 Decision

S4-M111 is closed for the current generic repeated weighted index batch bar:
callers can now fill caller-owned weighted index buffers or request owned
repeated weighted index slices for integer or float weights through `seq`.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
