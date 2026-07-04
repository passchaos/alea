# S4-M170 Index-Weighted Choice Arrays

Result: passed.

Purpose: add fixed-size repeated with-replacement length/index-weight accessor
weighted index, compact u32-index, value, const-pointer, and mutable-pointer
choice arrays in `seq`. Before this milestone, index-weighted workflows had
one-shot choices, caller-owned fills, allocation-returning batches, reusable
sampler construction, and no-replacement fixed-size arrays. S4-M170 adds direct
stack-friendly `[N]...` outputs for repeated with-replacement draws while
keeping `sampleWeighted*ArrayByIndex` as no-replacement sampling.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/slice.rs` exposes `choose_weighted`,
  `choose_weighted_iter`, and `choose_weighted_mut` through item closures;
- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs` exposes
  generic weighted-index sampling over parallel weights;
- Rust length/index-weight workflows are assembled by sampling weighted indexes
  and mapping indexes back to items, typically through iterator or loop
  collection rather than a direct fixed-size stack array API.

This milestone keeps the Zig API explicit: `*ArrayByIndex` names under weighted
choice are repeated with-replacement outputs from a length/index-weight accessor,
while `sampleWeighted*ArrayByIndex` remains no-replacement.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.weightedIndexArrayByIndex`;
- `seq.weightedIndexArrayByIndexFrom`;
- `seq.weightedIndexArrayByIndexChecked`;
- `seq.weightedIndexArrayByIndexCheckedFrom`;
- `seq.weightedIndexU32ArrayByIndex`;
- `seq.weightedIndexU32ArrayByIndexFrom`;
- `seq.weightedIndexU32ArrayByIndexChecked`;
- `seq.weightedIndexU32ArrayByIndexCheckedFrom`;
- `seq.chooseWeightedValueArrayByIndex`;
- `seq.chooseWeightedValueArrayByIndexFrom`;
- `seq.chooseWeightedValueArrayByIndexChecked`;
- `seq.chooseWeightedValueArrayByIndexCheckedFrom`;
- `seq.chooseWeightedConstPtrArrayByIndex`;
- `seq.chooseWeightedConstPtrArrayByIndexFrom`;
- `seq.chooseWeightedConstPtrArrayByIndexChecked`;
- `seq.chooseWeightedConstPtrArrayByIndexCheckedFrom`;
- `seq.chooseWeightedPtrArrayByIndex`;
- `seq.chooseWeightedPtrArrayByIndexFrom`;
- `seq.chooseWeightedPtrArrayByIndexChecked`;
- `seq.chooseWeightedPtrArrayByIndexCheckedFrom`.

The index helpers return `[N]usize`, compact index helpers return `[N]u32`,
value helpers return `[N]T`, const-pointer helpers return `[N]*const T`, and
mutable-pointer helpers return `[N]*T`.

Focused tests verify:

- facade and direct-source arrays preserve canonical stream shape for
  index-weighted index/u32-index/value/const-pointer/mutable-pointer arrays;
- zero-length checked arrays return before validating or drawing;
- all-zero optional arrays return `null` without drawing;
- checked all-zero/empty inputs return `error.EmptyInput` without drawing;
- invalid weights and oversized `u32` populations are rejected without drawing;
- single-positive weights fill deterministic arrays without consuming the
  random stream.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints
  `weighted index-weight repeated index array`,
  `weighted index-weight repeated u32 index array`,
  `weighted index-weight repeated value array`,
  `weighted index-weight repeated const ptr array`, and
  `weighted index-weight repeated mut ptr array items` rows.
- `tools/examplecheck.zig` verifies those example tokens and summary API tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the repeated index-weight accessor fixed-array semantics.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "index-weighted weightedIndexByIndex"`
- `zig test src/root.zig --test-filter "index-weighted chooseWeightedByIndex"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked index-weight accessor repeated stack-output
ergonomics gap only. It does not resolve S4-M11's exact/default-compatible dense
SIMD normal/exponential blocker, does not add a new architecture/runtime runner,
and is not whole-goal completion evidence.
