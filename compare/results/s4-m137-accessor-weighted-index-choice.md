# S4-M137 Accessor-Weighted One-Shot Indexes

Result: passed.

Purpose: expose the index selected by item-derived weighted choices directly.
Alea already had one-shot accessor weighted value/const-pointer/mutable-pointer
choices, no-replacement accessor-weighted index samples, and repeated
accessor-weighted fills/batches. This milestone adds direct one-shot `usize` and
`u32` weighted-index helpers for item-derived weights.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs`:

- `IndexedRandom::choose_weighted(rng, |item| ...)` constructs a weighted-index
  distribution over item-derived weights and returns a selected reference;
- `IndexedMutRandom::choose_weighted_mut(rng, |item| ...)` provides the mutable
  reference variant.

Rust exposes references for those APIs. Alea now additionally exposes the chosen
index directly, which is useful when callers need to record positions, map
through `IndexVec`-style workflows, or apply their own item projection after
sampling.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.weightedIndexBy`;
- `seq.weightedIndexByFrom`;
- `seq.weightedIndexByChecked`;
- `seq.weightedIndexByCheckedFrom`;
- `seq.weightedIndexU32By`;
- `seq.weightedIndexU32ByFrom`;
- `seq.weightedIndexU32ByChecked`;
- `seq.weightedIndexU32ByCheckedFrom`.

Optional forms return `null` for empty or all-zero item weights. Checked forms
map those paths to `error.EmptyInput`. The compact `u32` forms reject item slices
longer than `maxInt(u32)` before narrowing indexes. Negative, non-finite, or
overflowing item-derived totals return `error.InvalidWeight`.

Focused tests verify:

- one-shot `usize` and `u32` index selection from item accessors;
- facade/direct stream-shape parity for `ScalarPrng` and `DefaultPrng`;
- empty/all-zero optional no-consume behavior;
- checked empty/all-zero no-consume behavior;
- single-positive no-consume behavior;
- invalid-weight no-consume behavior.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `weighted by one-shot index` and
  `weighted by one-shot u32 index` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the accessor-weighted one-shot index helpers.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "accessor weightedIndexBy"`
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
