# S4-M125 Index-Weighted No-Replacement Samples

Result: passed.

Purpose: cover local Rust `rand`'s length-based weighted index sampling shape
without forcing callers to allocate or maintain a parallel weight slice. Alea
already had parallel-weight and item-accessor weighted no-replacement sampling;
this milestone adds Zig-native index-weight accessors for the Rust
`index::sample_weighted(rng, length, |index| ...)` workflow.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/index.rs`:

- `index::sample_weighted(rng, length, weight, amount)` calls `weight(index)`
  once for each index;
- it returns an `IndexVec`;
- if there are fewer positive weights than requested, the result may contain
  fewer than `amount` indexes;
- non-finite or negative weights are errors.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.sampleWeightedIndicesByIndex`;
- `seq.sampleWeightedIndicesByIndexFrom`;
- `seq.sampleWeightedIndicesByIndexChecked`;
- `seq.sampleWeightedIndicesByIndexCheckedFrom`;
- `seq.sampleWeightedIndicesU32ByIndex`;
- `seq.sampleWeightedIndicesU32ByIndexFrom`;
- `seq.sampleWeightedIndicesU32ByIndexChecked`;
- `seq.sampleWeightedIndicesU32ByIndexCheckedFrom`;
- `seq.sampleWeightedIndexVecByIndex`;
- `seq.sampleWeightedIndexVecByIndexFrom`;
- `seq.sampleWeightedIndexVecByIndexChecked`;
- `seq.sampleWeightedIndexVecByIndexCheckedFrom`.

These accept a `length` and a comptime `fn (usize) Weight` accessor, then sample
distinct indexes using the existing Efraimidis-Spirakis-style key selection
helpers. Optional forms truncate to available positive weights, checked forms
require enough positive weights, and `u32` / compact `IndexVec` forms reject
lengths that cannot fit their output representation.

Focused tests cover:

- usize, u32, and `IndexVec` outputs;
- checked and optional behavior when requested samples exceed positive weights;
- zero-count no-consume behavior before validating weights;
- single-positive no-consume behavior;
- invalid length/count/weight no-consume behavior;
- facade/direct stream-shape parity.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `weighted index-weight indices`,
  `weighted index-weight u32 indices`, and `weighted index-weight IndexVec`.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the index-weight accessor workflow.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "index-weighted"`
- `zig build test`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked weighted sequence API gap only. It does not
resolve S4-M11's exact/default-compatible dense SIMD normal/exponential blocker,
does not add a new architecture/runtime runner, and is not whole-goal completion
evidence.
