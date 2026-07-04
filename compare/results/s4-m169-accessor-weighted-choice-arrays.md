# S4-M169 Accessor Weighted Choice Arrays

Result: passed.

Purpose: add fixed-size repeated with-replacement item-accessor weighted index,
compact u32-index, value, const-pointer, and mutable-pointer choice arrays in
`seq`. Before this milestone, accessor-weighted workflows had one-shot choices,
caller-owned fills, allocation-returning batches, and no-replacement fixed-size
samples. S4-M169 adds direct stack-friendly repeated `[N]...` outputs for the
with-replacement side while keeping `sampleWeighted*ArrayBy` as no-replacement
sampling.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/slice.rs` exposes `choose_weighted`,
  `choose_weighted_iter`, and `choose_weighted_mut` through closures over item
  weights;
- repeated weighted-reference workflows in Rust are assembled through iterator
  or loop collection;
- Alea already exposes accessor-weighted one-shot, fill, batch, and
  no-replacement array APIs.

This milestone keeps the Zig API explicit: `*ArrayBy` names under weighted
choice are repeated with-replacement outputs, while `sampleWeighted*ArrayBy`
remains no-replacement.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.weightedIndexArrayBy`;
- `seq.weightedIndexArrayByFrom`;
- `seq.weightedIndexArrayByChecked`;
- `seq.weightedIndexArrayByCheckedFrom`;
- `seq.weightedIndexU32ArrayBy`;
- `seq.weightedIndexU32ArrayByFrom`;
- `seq.weightedIndexU32ArrayByChecked`;
- `seq.weightedIndexU32ArrayByCheckedFrom`;
- `seq.chooseWeightedValueArrayBy`;
- `seq.chooseWeightedValueArrayByFrom`;
- `seq.chooseWeightedValueArrayByChecked`;
- `seq.chooseWeightedValueArrayByCheckedFrom`;
- `seq.chooseWeightedConstPtrArrayBy`;
- `seq.chooseWeightedConstPtrArrayByFrom`;
- `seq.chooseWeightedConstPtrArrayByChecked`;
- `seq.chooseWeightedConstPtrArrayByCheckedFrom`;
- `seq.chooseWeightedPtrArrayBy`;
- `seq.chooseWeightedPtrArrayByFrom`;
- `seq.chooseWeightedPtrArrayByChecked`;
- `seq.chooseWeightedPtrArrayByCheckedFrom`.

The index helpers return `[N]usize`, compact index helpers return `[N]u32`,
value helpers return `[N]T`, const-pointer helpers return `[N]*const T`, and
mutable-pointer helpers return `[N]*T`.

Focused tests verify:

- facade and direct-source arrays preserve canonical stream shape for
  item-accessor weighted index/u32-index/value/const-pointer/mutable-pointer
  arrays;
- zero-length checked arrays return before validating or drawing;
- all-zero optional arrays return `null` without drawing;
- checked all-zero/empty inputs return `error.EmptyInput` without drawing;
- invalid weights are rejected without drawing;
- single-positive weights fill deterministic arrays without consuming the
  random stream.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `weighted by repeated index array`,
  `weighted by repeated u32 index array`, `weighted by repeated value array`,
  `weighted by repeated const ptr array`, and
  `weighted by repeated mut ptr array` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the repeated item-accessor weighted fixed-array semantics.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "accessor weightedIndexBy selects indexes"`
- `zig test src/root.zig --test-filter "accessor weightedIndexBy preserves facade/direct stream shape and invalid paths do not consume"`
- `zig test src/root.zig --test-filter "chooseWeightedBy selects values and pointers"`
- `zig test src/root.zig --test-filter "chooseWeightedBy preserves facade/direct stream shape and invalid paths do not consume"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked item-accessor weighted repeated stack-output
ergonomics gap only. It does not resolve S4-M11's exact/default-compatible dense
SIMD normal/exponential blocker, does not add a new architecture/runtime runner,
and is not whole-goal completion evidence.
