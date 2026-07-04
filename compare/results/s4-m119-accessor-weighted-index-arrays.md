# S4-M119 Accessor-Based Weighted Index Arrays

Result: passed.

Purpose: add fixed-size, allocation-free accessor-weighted index array helpers.
This complements S4-M118's allocation-returning accessor-weighted index/u32/
IndexVec samples, existing parallel-weight `sampleWeightedIndexArray*`, and the
local Rust `sample_array` plus `sample_weighted(..., |item| ...)` ergonomics.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs`:

- `sample_array` returns fixed-size arrays without allocating;
- `sample_weighted` accepts item-derived weights via a closure but returns an
  iterator over sampled references;
- Alea combines these ideas in Zig-native fixed-size accessor-weighted index
  array helpers.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.sampleWeightedIndexArrayBy` /
  `seq.sampleWeightedIndexArrayByFrom`;
- `seq.sampleWeightedIndexArrayByChecked` /
  `seq.sampleWeightedIndexArrayByCheckedFrom`;
- `seq.sampleWeightedIndexArrayU32By` /
  `seq.sampleWeightedIndexArrayU32ByFrom`;
- `seq.sampleWeightedIndexArrayU32ByChecked` /
  `seq.sampleWeightedIndexArrayU32ByCheckedFrom`.

Optional forms return `null` when too few positive-weight entries are available.
Checked forms return `error.InvalidParameter` for too-few positives or invalid
counts. Zero-size arrays return before validating weights. Single-positive
`N == 1` paths return the deterministic index without consuming random stream
state. Invalid weights are rejected before drawing.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints:
  - `weighted by index array`
  - `weighted by u32 index array`
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the fixed-size accessor-weighted index array workflows.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig build test`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked sequence ergonomics/storage gap only. It does
not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
