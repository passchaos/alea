# S4-M126 Caller-Owned Index-Weighted Buffers

Result: passed.

Purpose: extend S4-M125's length-based index weight accessors to caller-owned
output buffers. This complements existing parallel-weight
`sampleWeightedIndicesInto*` and item-accessor `sampleWeightedIndicesByInto*`
helpers while preserving the local Rust `index::sample_weighted(rng, length,
|index| ...)` workflow shape for users who adapt sampled indexes into fixed
buffers.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/index.rs`:

- `index::sample_weighted(rng, length, weight, amount)` calls `weight(index)`
  once for each index;
- it returns an `IndexVec`, which users commonly adapt into their own storage;
- if there are fewer positive weights than requested, the result may contain
  fewer than `amount` indexes;
- non-finite or negative weights are errors.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.sampleWeightedIndicesByIndexInto`;
- `seq.sampleWeightedIndicesByIndexIntoFrom`;
- `seq.sampleWeightedIndicesByIndexIntoChecked`;
- `seq.sampleWeightedIndicesByIndexIntoCheckedFrom`;
- `seq.sampleWeightedIndicesU32ByIndexInto`;
- `seq.sampleWeightedIndicesU32ByIndexIntoFrom`;
- `seq.sampleWeightedIndicesU32ByIndexIntoChecked`;
- `seq.sampleWeightedIndicesU32ByIndexIntoCheckedFrom`.

These accept a `length`, a caller-owned output slice, caller-owned scratch keys,
and a comptime `fn (usize) Weight` accessor. Optional forms fill up to the
available positive weights and return the count written; checked forms require
the output length to be fully satisfiable. `u32` variants reject lengths that do
not fit the compact output representation.

Focused tests cover:

- usize and u32 caller-owned outputs;
- checked and optional behavior when requested samples exceed positive weights;
- scratch-length errors;
- zero-count no-consume behavior before validating weights;
- single-positive no-consume behavior;
- invalid length/count/weight no-consume behavior;
- facade/direct stream-shape parity.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `weighted index-weight indices into`
  and `weighted index-weight u32 indices into`.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the caller-owned index-weight workflow.

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

This milestone closes an unblocked weighted sequence ergonomics gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
