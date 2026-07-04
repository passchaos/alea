# S4-M127 Fixed-Size Index-Weighted Arrays

Result: passed.

Purpose: extend the length-based index weight accessor workflow to fixed-size
arrays. This complements S4-M125 allocation-returning and S4-M126 caller-owned
index-weighted helpers, existing parallel-weight `sampleWeightedIndexArray*`,
item-accessor weighted arrays, and local Rust `index::sample_weighted(rng,
length, |index| ...)` workflows that users adapt into fixed-size arrays.

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

- `seq.sampleWeightedIndexArrayByIndex`;
- `seq.sampleWeightedIndexArrayByIndexFrom`;
- `seq.sampleWeightedIndexArrayByIndexChecked`;
- `seq.sampleWeightedIndexArrayByIndexCheckedFrom`;
- `seq.sampleWeightedIndexArrayU32ByIndex`;
- `seq.sampleWeightedIndexArrayU32ByIndexFrom`;
- `seq.sampleWeightedIndexArrayU32ByIndexChecked`;
- `seq.sampleWeightedIndexArrayU32ByIndexCheckedFrom`.

These accept a `length`, a comptime `fn (usize) Weight` accessor, and a comptime
array length `N`. Optional forms return `null` when fewer than `N` positive
weights exist; checked forms return `error.InvalidParameter`; `u32` variants
reject lengths that do not fit the compact output representation.

Focused tests cover:

- usize and u32 fixed-size arrays;
- checked and optional behavior when requested samples exceed positive weights;
- zero-count no-consume behavior before validating weights;
- single-positive no-consume behavior;
- invalid length/count/weight no-consume behavior.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `weighted index-weight index array`
  and `weighted index-weight u32 index array`.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the fixed-size index-weight workflow.

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
