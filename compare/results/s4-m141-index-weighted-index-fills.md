# S4-M141 Index-Weighted Index Fills

Result: passed.

Purpose: fill caller-owned repeated weighted-index buffers from a length and a
comptime index-weight function. S4-M140 added the one-shot choice form; this
milestone adds the caller-owned repeated `usize` and compact `u32` index-fill
forms, matching the ergonomics of parallel-weight `fillWeightedIndex*` while
avoiding a parallel weight slice.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/index.rs`:

- `index::sample_weighted(rng, length, |index| ...)` samples indexes from a
  length and index-derived weight function without requiring a parallel weight
  slice.

Alea already covers no-replacement index-weighted samples, buffers, fixed-size
arrays, `IndexVec`, and S4-M140 one-shot choices. This milestone adds repeated
with-replacement caller-owned index fills for the same length/index-weight source.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.fillWeightedIndexByIndex`;
- `seq.fillWeightedIndexByIndexFrom`;
- `seq.fillWeightedIndexByIndexChecked`;
- `seq.fillWeightedIndexByIndexCheckedFrom`;
- `seq.fillWeightedIndexU32ByIndex`;
- `seq.fillWeightedIndexU32ByIndexFrom`;
- `seq.fillWeightedIndexU32ByIndexChecked`;
- `seq.fillWeightedIndexU32ByIndexCheckedFrom`.

Optional output buffers (`[]?usize`, `[]?u32`) represent length-zero or all-zero
index weights with `null` entries. Checked output buffers reject those paths with
`error.EmptyInput`. Compact `u32` fills reject lengths larger than `maxInt(u32)`
before narrowing indexes.

Focused tests verify:

- `usize` and `u32` caller-owned output buffers;
- facade/direct stream-shape parity for `ScalarPrng` and `DefaultPrng`;
- zero-length destination no-consume behavior before validating weights;
- length-zero/all-zero optional no-consume behavior;
- checked length-zero/all-zero no-consume behavior;
- single-positive no-consume behavior;
- invalid-weight no-consume behavior;
- oversized compact-u32 no-consume behavior.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `weighted index-weight index fill` and
  `weighted index-weight u32 index fill` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the index-weighted index fill helpers.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "fillWeightedIndexByIndex"`
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
