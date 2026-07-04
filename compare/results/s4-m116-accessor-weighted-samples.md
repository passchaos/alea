# S4-M116 Accessor-Based Weighted No-Replacement Samples

Result: passed.

Purpose: close the local Rust sequence ergonomics gap around
`IndexedRandom::sample_weighted(&mut rng, amount, |item| ...)`, where weights are
read or derived from each item. S4-M115 added accessor-based one-shot weighted
choices; this milestone extends the same Zig-native design to allocation-returning
weighted no-replacement samples.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs`:

- `sample_weighted(&mut rng, amount, |item| item.1)` samples distinct weighted
  references using an item weight accessor;
- deprecated `choose_multiple_weighted` forwards to `sample_weighted`;
- local Rust returns references. Alea intentionally exposes Zig-native value,
  const-pointer, and mutable-pointer allocation-returning forms rather than
  Rust trait/iterator shapes.

## Alea API Added

`src/seq.zig` now exposes accessor-based weighted no-replacement helpers:

- `seq.sampleWeightedBy` / `seq.sampleWeightedByFrom`;
- `seq.sampleWeightedByChecked` / `seq.sampleWeightedByCheckedFrom`;
- `seq.sampleWeightedPtrsBy` / `seq.sampleWeightedPtrsByFrom`;
- `seq.sampleWeightedPtrsByChecked` / `seq.sampleWeightedPtrsByCheckedFrom`;
- `seq.sampleWeightedMutPtrsBy` / `seq.sampleWeightedMutPtrsByFrom`;
- `seq.sampleWeightedMutPtrsByChecked` /
  `seq.sampleWeightedMutPtrsByCheckedFrom`.

The accessor is a comptime `fn (*const T) Weight`, matching the S4-M115 one-shot
shape. Optional/count-clamping forms return as many positive-weight items as are
available; checked forms require enough positive-weight items. Zero-count calls
return an empty allocation before validating weights. Invalid weights and invalid
checked counts return before drawing. Single-positive accessors return the
single deterministic value/pointer without consuming random stream state.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints:
  - `weighted by no-replacement sample`
  - `weighted by no-replacement ptrs`
  - `weighted by no-replacement mut ptr scores`
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the accessor-based no-replacement workflows.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig build test`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked sequence ergonomics gap only. It does not
resolve S4-M11's exact/default-compatible dense SIMD normal/exponential blocker,
does not add a new architecture/runtime runner, and is not whole-goal completion
evidence.
