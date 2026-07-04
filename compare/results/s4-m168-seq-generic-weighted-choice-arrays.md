# S4-M168 Seq Generic Weighted Choice Arrays

Result: passed.

Purpose: add fixed-size repeated with-replacement generic-weight index, compact
u32-index, value, const-pointer, and mutable-pointer choice arrays in the `seq`
namespace. Before this milestone, `seq` had generic-weight one-shot choices,
caller-owned fills, and heap-owned batches for repeated weighted draws, while
S4-M167 added f64-specific direct `Rng` stack arrays. This left a stack-output
gap for integer-weight and generic-float weighted choice workflows.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs` supports
  generic integer and float weights through `WeightedIndex`;
- `/home/passchaos/Work/rand/src/seq/slice.rs` exposes `choose_weighted`,
  `choose_weighted_iter`, and `choose_weighted_mut` over item-derived weights;
- Rust repeated weighted choices are normally assembled by iterator/loop
  collection rather than a direct fixed-size stack array API.

This milestone keeps Alea Zig-native by exposing stack-friendly `[N]...`
results for parallel generic-weight slices while keeping existing
`seq.sampleWeighted*Array` helpers as no-replacement weighted samples.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.weightedIndexArray`;
- `seq.weightedIndexArrayFrom`;
- `seq.weightedIndexArrayChecked`;
- `seq.weightedIndexArrayCheckedFrom`;
- `seq.weightedIndexU32Array`;
- `seq.weightedIndexU32ArrayFrom`;
- `seq.weightedIndexU32ArrayChecked`;
- `seq.weightedIndexU32ArrayCheckedFrom`;
- `seq.chooseWeightedValueArray`;
- `seq.chooseWeightedValueArrayFrom`;
- `seq.chooseWeightedValueArrayChecked`;
- `seq.chooseWeightedValueArrayCheckedFrom`;
- `seq.chooseWeightedConstPtrArray`;
- `seq.chooseWeightedConstPtrArrayFrom`;
- `seq.chooseWeightedConstPtrArrayChecked`;
- `seq.chooseWeightedConstPtrArrayCheckedFrom`;
- `seq.chooseWeightedPtrArray`;
- `seq.chooseWeightedPtrArrayFrom`;
- `seq.chooseWeightedPtrArrayChecked`;
- `seq.chooseWeightedPtrArrayCheckedFrom`.

The index helpers return `[N]usize`, compact index helpers return `[N]u32`,
value helpers return `[N]T`, const-pointer helpers return `[N]*const T`, and
mutable-pointer helpers return `[N]*T`.

Focused tests verify:

- facade and direct-source arrays preserve canonical fill stream shape for
  generic weighted index/u32-index/value/const-pointer/mutable-pointer arrays;
- zero-length checked arrays return before validating or drawing;
- all-zero optional arrays return `null` without drawing;
- checked all-zero/empty inputs return `error.EmptyInput` without drawing;
- invalid weights and length mismatches are rejected without drawing;
- single-positive weights fill deterministic arrays without consuming the
  random stream.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `generic weighted index array`,
  `generic weighted u32 index array`, `generic weighted value array`,
  `generic weighted const ptr array`, and `generic weighted mut ptr array`
  rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the repeated generic-weight fixed-array semantics.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "generic weightedIndex selects indexes"`
- `zig test src/root.zig --test-filter "generic weightedIndex preserves facade/direct stream shape and invalid paths do not consume"`
- `zig test src/root.zig --test-filter "chooseWeighted selects values and mutable pointers"`
- `zig test src/root.zig --test-filter "chooseWeighted preserves facade/direct stream shape and invalid paths do not consume"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked `seq` generic-weight repeated choice
stack-output ergonomics gap only. It does not resolve S4-M11's
exact/default-compatible dense SIMD normal/exponential blocker, does not add a
new architecture/runtime runner, and is not whole-goal completion evidence.
