# S4-M115 Accessor-Based Weighted Choices

Result: passed.

Purpose: close the remaining local Rust sequence ergonomics gap around
`IndexedRandom::choose_weighted` and `IndexedMutRandom::choose_weighted_mut`
where weights are derived from each item by a closure. Alea already had
parallel-slice weighted indexes, values, const pointers, mutable pointers,
reusable `WeightedChoice`, repeated batches, and no-replacement workflows; this
milestone adds Zig-native comptime accessor forms for one-shot item-embedded or
derived weights without copying Rust trait machinery.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs`:

- `choose_weighted(&mut rng, |item| item.1)` builds a weighted index from an
  item weight accessor and returns `&Self::Output`;
- `choose_weighted_mut(&mut rng, |item| item.1)` does the same and returns a
  mutable reference;
- `choose_weighted_iter` is the repeated-reference form, already covered by
  Alea's reusable `WeightedChoice`, `Rng.chooseWeighted*Batch`, and S4-M111
  through S4-M114 generic repeated weighted batches.

## Alea API Added

`src/seq.zig` now exposes accessor-based one-shot helpers:

- `seq.chooseWeightedBy` / `seq.chooseWeightedByFrom`;
- `seq.chooseWeightedByChecked` / `seq.chooseWeightedByCheckedFrom`;
- `seq.chooseWeightedConstPtrBy` / `seq.chooseWeightedConstPtrByFrom`;
- `seq.chooseWeightedConstPtrByChecked` /
  `seq.chooseWeightedConstPtrByCheckedFrom`;
- `seq.chooseWeightedPtrBy` / `seq.chooseWeightedPtrByFrom`;
- `seq.chooseWeightedPtrByChecked` / `seq.chooseWeightedPtrByCheckedFrom`.

The accessor is a comptime `fn (*const T) Weight`, so callers can keep weights
inside item records or derive weights from item state while still getting a
Zig-native API shape. Optional forms return `null` for empty/all-zero item
weights; checked forms return `error.EmptyInput`; non-finite or negative weights
return `error.InvalidWeight` before drawing. Single-positive accessors return
the deterministic item/pointer without consuming random stream state.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints:
  - `weighted by value`
  - `weighted by const ptr`
  - `weighted by mut ptr score`
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the accessor-based workflows.

## Validation

The relevant validation for this milestone is:

- `zig build test`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked sequence ergonomics gap only. It does not
resolve S4-M11's exact/default-compatible dense SIMD normal/exponential blocker,
does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
