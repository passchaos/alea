# S4-M107 Rng Repeated Weighted U32 Index Batches

Date: 2026-07-04

Purpose: add caller-owned and allocation-returning repeated compact weighted
index helpers for `Rng`. This complements one-shot `Rng.weightedIndexU32`,
S4-M106 usize weighted index batches, reusable weighted choice u32 batches, and
compact local Rust-style repeated weighted index loops.

## Rust rand Comparison

Rust weighted index APIs are typically sampled repeatedly through loops or
reusable distributions. Alea already had one-shot compact `weightedIndexU32`,
S4-M106 repeated `usize` weighted index batches, generic compact weighted index
helpers in `seq`, and reusable `WeightedChoice.indicesU32*`; S4-M107 adds direct
`Rng` caller-owned and owned repeated compact f64 weighted index helpers.

## Change

Added repeated compact weighted index helpers in `src/rng.zig`:

- `Rng.fillWeightedIndexU32(dest, weights)` for optional `?u32` outputs;
- `Rng.fillWeightedIndexU32From(source, dest, weights)`;
- `Rng.weightedIndexU32Batch(allocator, count, weights)` returning `[]?u32`;
- `Rng.weightedIndexU32BatchFrom(source, allocator, count, weights)`;
- `Rng.fillWeightedIndexU32Checked(dest, weights)` for non-null `u32` outputs;
- `Rng.fillWeightedIndexU32CheckedFrom(source, dest, weights)`;
- `Rng.weightedIndexU32BatchChecked(allocator, count, weights)` returning `[]u32`;
- `Rng.weightedIndexU32BatchCheckedFrom(source, allocator, count, weights)`.

The checked helpers validate weights and u32-representable length before drawing
or allocating for positive counts, return zero-count slices before validation,
reject empty/all-zero weights as `EmptyRange` for non-optional checked output,
and preserve single-positive and allocation-failure no-consume behavior.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints a `weighted u32 index batch` row;
- `tools/examplecheck.zig` guards the example token;
- `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, and
  `README.md` list the new APIs;
- `compare/results/linux-no-known-gaps-audit.md` includes S4-M107 evidence.

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

- checked/unchecked repeated weighted-u32-index stream-shape parity;
- optional `[]?u32` and checked `[]u32` output shapes;
- single-positive no-consume behavior;
- zero-length checked fills and zero-count checked batches returning before
  validation;
- invalid/non-finite weights, all-zero weights, and allocation-failure paths
  returning before stream consumption where validation can happen first.

## S4-M107 Decision

S4-M107 is closed for the current repeated compact f64 weighted index batch bar:
callers can now fill caller-owned weighted-u32-index buffers or request owned
repeated weighted-u32-index slices directly from `Rng`.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
