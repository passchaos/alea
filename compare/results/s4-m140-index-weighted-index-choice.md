# S4-M140 Index-Weighted One-Shot Indexes

Result: passed.

Purpose: expose direct one-shot weighted-index selection from a length and a
comptime index-weight function. Alea already had index-weighted no-replacement
samples, caller-owned buffers, and fixed-size arrays; this milestone adds the
with-replacement one-shot `usize` and compact `u32` index choice forms.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/index.rs`:

- `index::sample_weighted(rng, length, |index| ...)` samples indexes from a
  length and index-derived weight function without requiring a parallel weight
  slice;
- Alea already exceeds the Rust no-replacement surface with allocation-returning,
  caller-owned, fixed-size, and `IndexVec` index-weighted samples.

This milestone adds the one-shot weighted index counterpart for callers who need
a single index from the same length/index-weight source.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.weightedIndexByIndex`;
- `seq.weightedIndexByIndexFrom`;
- `seq.weightedIndexByIndexChecked`;
- `seq.weightedIndexByIndexCheckedFrom`;
- `seq.weightedIndexU32ByIndex`;
- `seq.weightedIndexU32ByIndexFrom`;
- `seq.weightedIndexU32ByIndexChecked`;
- `seq.weightedIndexU32ByIndexCheckedFrom`.

Optional forms return `null` for length zero or all-zero index weights. Checked
forms map those paths to `error.EmptyInput`. Compact `u32` forms reject lengths
larger than `maxInt(u32)` before narrowing. Negative, non-finite, or overflowing
index-derived totals return `error.InvalidWeight`.

Focused tests verify:

- one-shot `usize` and `u32` index selection from length/index weights;
- facade/direct stream-shape parity for `ScalarPrng` and `DefaultPrng`;
- length-zero/all-zero optional no-consume behavior;
- checked length-zero/all-zero no-consume behavior;
- single-positive no-consume behavior;
- invalid-weight no-consume behavior;
- oversized compact-u32 no-consume behavior.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `weighted index-weight one-shot index`
  and `weighted index-weight one-shot u32 index` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the index-weighted one-shot helpers.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "weightedIndexByIndex"`
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
