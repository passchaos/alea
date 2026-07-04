# S4-M118 Accessor-Based Weighted Index Samples

Result: passed.

Purpose: close the local Rust low-level weighted-index ergonomics gap around
`rand::seq::index::sample_weighted(rng, length, |index| weight, amount)`. Earlier
S4-M115 through S4-M117 added accessor-based item choices, allocation-returning
item/pointer samples, and caller-owned buffers. This milestone adds
allocation-returning accessor-weighted index outputs directly.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/index.rs` and
`/home/passchaos/Work/rand/src/seq/slice.rs`:

- `index::sample_weighted(rng, length, |index| ..., amount)` returns an
  `IndexVec` from an index weight closure;
- slice `sample_weighted` maps item closures through that low-level index API;
- results may contain fewer than `amount` entries when too few positive weights
  exist.

## Alea API Added

`src/seq.zig` now exposes allocation-returning accessor-weighted index helpers:

- `seq.sampleWeightedIndicesBy` / `seq.sampleWeightedIndicesByFrom`;
- `seq.sampleWeightedIndicesByChecked` /
  `seq.sampleWeightedIndicesByCheckedFrom`;
- `seq.sampleWeightedIndicesU32By` / `seq.sampleWeightedIndicesU32ByFrom`;
- `seq.sampleWeightedIndicesU32ByChecked` /
  `seq.sampleWeightedIndicesU32ByCheckedFrom`;
- `seq.sampleWeightedIndexVecBy` / `seq.sampleWeightedIndexVecByFrom`;
- `seq.sampleWeightedIndexVecByChecked` /
  `seq.sampleWeightedIndexVecByCheckedFrom`.

The accessor is a comptime `fn (*const T) Weight`, matching the prior S4
accessor APIs. Optional/count-clamping forms return as many positive-weight
indexes as available. Checked forms require enough positive-weight entries.
Zero-count calls return empty allocations before validating weights. Invalid
weights and invalid checked counts return before drawing. Single-positive
accessors return the deterministic index without consuming stream state.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints:
  - `weighted by no-replacement indices`
  - `weighted by u32 no-replacement indices`
  - `weighted by IndexVec`
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the allocation-returning accessor-weighted index workflows.

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
