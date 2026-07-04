# S4-M142 Index-Weighted Index Batches

Result: passed.

Purpose: allocate repeated weighted-index batches from a length and a comptime
index-weight function. S4-M141 added the caller-owned fill form; this milestone
adds allocation-returning `usize` and compact `u32` index batches, matching the
ergonomics of parallel-weight `weightedIndex*Batch` and accessor-weighted
`weightedIndex*BatchBy` while avoiding a parallel weight slice.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/index.rs` and
`/home/passchaos/Work/rand/src/seq/slice.rs`:

- `index::sample_weighted(rng, length, |index| ...)` samples indexes from a
  length and index-derived weight function without requiring a parallel weight
  slice;
- `choose_weighted_iter(...).take(n).collect()` is the local Rust repeated
  with-replacement workflow for owned repeated weighted choices.

Alea already covers no-replacement index-weighted samples, caller-owned buffers,
fixed-size arrays, `IndexVec`, S4-M140 one-shot choices, and S4-M141
caller-owned repeated fills. This milestone adds owned repeated
with-replacement index batches for the same length/index-weight source.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.weightedIndexBatchByIndex`;
- `seq.weightedIndexBatchByIndexFrom`;
- `seq.weightedIndexBatchByIndexChecked`;
- `seq.weightedIndexBatchByIndexCheckedFrom`;
- `seq.weightedIndexU32BatchByIndex`;
- `seq.weightedIndexU32BatchByIndexFrom`;
- `seq.weightedIndexU32BatchByIndexChecked`;
- `seq.weightedIndexU32BatchByIndexCheckedFrom`.

Optional output batches (`[]?usize`, `[]?u32`) represent length-zero or all-zero
index weights with `null` entries. Checked batches reject those paths with
`error.EmptyInput`. Compact `u32` batches reject lengths larger than
`maxInt(u32)` before narrowing indexes. Zero-count batches allocate empty
outputs before validating weights or drawing.

Focused tests verify:

- `usize` and `u32` allocation-returning batches;
- facade/direct stream-shape parity for `ScalarPrng` and `DefaultPrng`;
- zero-count no-consume behavior before validating weights;
- length-zero/all-zero optional no-consume behavior;
- checked length-zero/all-zero no-consume behavior;
- single-positive no-consume behavior after allocation;
- invalid-weight no-consume behavior;
- oversized compact-u32 no-consume behavior;
- allocation-failure no-consume behavior.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `weighted index-weight index batch`
  and `weighted index-weight u32 index batch` rows.
- `tools/examplecheck.zig` verifies those example tokens and the summary token.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the index-weighted index batch helpers.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "weightedIndexBatchByIndex"`
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
