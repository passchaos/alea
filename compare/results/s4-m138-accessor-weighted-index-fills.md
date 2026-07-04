# S4-M138 Accessor-Weighted Index Fills

Result: passed.

Purpose: fill caller-owned repeated weighted-index buffers from item-derived
weights. S4-M137 added one-shot accessor weighted indexes; this milestone adds
the caller-owned repeated index-fill form for both `usize` and compact `u32`
indexes, matching the ergonomics of parallel-weight `fillWeightedIndex*`.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs`:

- `IndexedRandom::choose_weighted(rng, |item| ...)` constructs a weighted-index
  distribution over item-derived weights;
- `IndexedRandom::choose_weighted_iter(rng, |item| ...)` repeats that weighted
  selection with replacement.

Rust returns item references. Alea additionally exposes caller-owned index fills
so users can record positions directly, then map those positions to values or
pointers through existing Zig sequence helpers.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.fillWeightedIndexBy`;
- `seq.fillWeightedIndexByFrom`;
- `seq.fillWeightedIndexByChecked`;
- `seq.fillWeightedIndexByCheckedFrom`;
- `seq.fillWeightedIndexU32By`;
- `seq.fillWeightedIndexU32ByFrom`;
- `seq.fillWeightedIndexU32ByChecked`;
- `seq.fillWeightedIndexU32ByCheckedFrom`.

Optional output buffers (`[]?usize`, `[]?u32`) represent empty or all-zero item
weights with `null` entries. Checked output buffers reject those paths with
`error.EmptyInput`. Compact `u32` fills reject item slices longer than
`maxInt(u32)` before narrowing indexes.

Focused tests verify:

- `usize` and `u32` caller-owned output buffers;
- facade/direct stream-shape parity for `ScalarPrng` and `DefaultPrng`;
- zero-length destination no-consume behavior before validating weights;
- empty/all-zero optional no-consume behavior;
- checked empty/all-zero no-consume behavior;
- single-positive no-consume behavior;
- invalid-weight no-consume behavior.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `weighted by index fill` and
  `weighted by u32 index fill` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the accessor-weighted index fill helpers.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "fillWeightedIndexBy"`
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
