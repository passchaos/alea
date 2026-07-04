# S4-M139 Accessor-Weighted Index Batches

Result: passed.

Purpose: allocate repeated weighted-index batches from item-derived weights.
S4-M138 added caller-owned fills; this milestone adds allocation-returning
`usize` and compact `u32` index batches, matching the ergonomics of
parallel-weight `weightedIndex*Batch`.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs`:

- `IndexedRandom::choose_weighted(rng, |item| ...)` constructs a weighted-index
  distribution over item-derived weights;
- `IndexedRandom::choose_weighted_iter(rng, |item| ...)` repeats weighted
  selection with replacement.

Rust callers may collect repeated weighted choices into owned storage. Alea now
also supports owned index batches directly, avoiding a reference-to-index
conversion step when callers want positions.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.weightedIndexBatchBy`;
- `seq.weightedIndexBatchByFrom`;
- `seq.weightedIndexBatchByChecked`;
- `seq.weightedIndexBatchByCheckedFrom`;
- `seq.weightedIndexU32BatchBy`;
- `seq.weightedIndexU32BatchByFrom`;
- `seq.weightedIndexU32BatchByChecked`;
- `seq.weightedIndexU32BatchByCheckedFrom`.

Optional output batches (`[]?usize`, `[]?u32`) represent empty or all-zero item
weights with `null` entries. Checked batches reject those paths with
`error.EmptyInput`. Compact `u32` batches reject item slices longer than
`maxInt(u32)` before narrowing indexes. Zero-count batches allocate empty
outputs before validating weights or drawing.

Focused tests verify:

- `usize` and `u32` allocation-returning batches;
- facade/direct stream-shape parity for `ScalarPrng` and `DefaultPrng`;
- zero-count no-consume behavior before validating weights;
- empty/all-zero optional no-consume behavior;
- checked empty/all-zero no-consume behavior;
- single-positive no-consume behavior after allocation;
- invalid-weight no-consume behavior;
- allocation-failure no-consume behavior.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `weighted by index batch` and
  `weighted by u32 index batch` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the accessor-weighted index batch helpers.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "weightedIndexBatchBy"`
- `zig build test`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked weighted sequence ergonomics gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
