# S4-M161 WeightedChoice Index Arrays

Result: passed.

Purpose: add fixed-size repeated index arrays to reusable weighted choices.
Static `AliasTable` gained fixed-size arrays in S4-M159, dynamic
`WeightedTree` / `WeightedIntTree` gained them in S4-M160, and one-shot
sequence workflows already expose `sampleWeightedIndexArray*`. Reusable
`WeightedChoice` still required caller-owned slices, heap-owned batches, or
value/pointer iterators for repeated with-replacement index samples.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/slice.rs` exposes weighted slice choice and
  weighted no-replacement workflows such as `choose_weighted`,
  `choose_weighted_mut`, and `sample_weighted`;
- `/home/passchaos/Work/rand/src/seq/index.rs` exposes
  `sample_weighted(rng, length, |index| ..., amount)` for index-weighted
  no-replacement workflows;
- cached local `rand_distr 0.6.0` exposes reusable weighted index samplers such
  as `WeightedAliasIndex` and `WeightedTreeIndex`.

Alea already exceeds the Rust shape with reusable `WeightedChoice` item and
index accessor construction, update, diagnostics, value/pointer/index samples,
caller-owned fills, and owned batches. This milestone completes the same
stack-friendly fixed-size repeated-index output shape now available on
`AliasTable`, dynamic weighted trees, and sequence weighted-index helpers.

## Alea API Added

`src/seq.zig` now exposes on `WeightedChoice(T, Weight)`:

- `WeightedChoice.indexArray`;
- `WeightedChoice.indexArrayFrom`;
- `WeightedChoice.indexArrayU32`;
- `WeightedChoice.indexArrayU32Checked`;
- `WeightedChoice.indexArrayU32From`;
- `WeightedChoice.indexArrayU32CheckedFrom`.

The `usize` helpers return `[N]usize`. The compact `u32` helpers return
`Error![N]u32`, inheriting the same population-size validation as
`fillIndicesU32From`.

Focused tests verify:

- fixed `usize` arrays match caller-owned `fillIndicesFrom` under identical
  seeds;
- fixed `u32` arrays match caller-owned `fillIndicesU32From` under identical
  seeds;
- facade and direct-source paths preserve stream shape for both unchecked and
  checked compact helpers;
- zero-length fixed arrays return without sampling;
- single-positive reusable weighted choices return deterministic arrays without
  consuming the random stream.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `WeightedChoice.indexArrayFrom` and
  `WeightedChoice.indexArrayU32From` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe fixed-size reusable weighted-choice index arrays.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "WeightedChoice index arrays"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked reusable weighted-choice stack-output
ergonomics gap only. It does not resolve S4-M11's exact/default-compatible dense
SIMD normal/exponential blocker, does not add a new architecture/runtime runner,
and is not whole-goal completion evidence.
