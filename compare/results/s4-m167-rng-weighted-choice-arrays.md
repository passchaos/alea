# S4-M167 Rng Weighted Choice Arrays

Result: passed.

Purpose: add fixed-size repeated f64 weighted index, compact u32-index, value,
const-pointer, and mutable-pointer choice arrays to `Rng`. Before this
milestone, `Rng` had one-shot weighted choices, caller-owned weighted fills, and
heap-owned weighted batches, while reusable `WeightedChoice`, `AliasTable`, and
dynamic weighted trees already had stack-friendly fixed-size repeated index or
value/pointer array shapes. This left a direct `Rng` stack-output gap for simple
parallel f64 weights and local Rust repeated weighted choice workflows.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs` exposes
  reusable `WeightedIndex` sampling for repeated weighted index draws;
- `/home/passchaos/Work/rand/src/seq/slice.rs` exposes `choose_weighted`,
  `choose_weighted_iter`, and `choose_weighted_mut` by building a
  `WeightedIndex` over slice indexes;
- Rust users collect repeated weighted choices through iterators or loops rather
  than a direct fixed-size stack array API.

This milestone keeps Alea Zig-native: direct `Rng` helpers return `[N]...` for
simple f64 weights, while reusable `WeightedChoice` / `AliasTable` remain the
preferred cached-table APIs for many repeated draws from stable weights.

## Alea API Added

`src/rng.zig` now exposes:

- `Rng.weightedIndexArray`;
- `Rng.weightedIndexArrayFrom`;
- `Rng.weightedIndexArrayChecked`;
- `Rng.weightedIndexArrayCheckedFrom`;
- `Rng.weightedIndexU32Array`;
- `Rng.weightedIndexU32ArrayFrom`;
- `Rng.weightedIndexU32ArrayChecked`;
- `Rng.weightedIndexU32ArrayCheckedFrom`;
- `Rng.chooseWeightedValueArray`;
- `Rng.chooseWeightedValueArrayFrom`;
- `Rng.chooseWeightedValueArrayChecked`;
- `Rng.chooseWeightedValueArrayCheckedFrom`;
- `Rng.chooseWeightedConstPtrArray`;
- `Rng.chooseWeightedConstPtrArrayFrom`;
- `Rng.chooseWeightedConstPtrArrayChecked`;
- `Rng.chooseWeightedConstPtrArrayCheckedFrom`;
- `Rng.chooseWeightedPtrArray`;
- `Rng.chooseWeightedPtrArrayFrom`;
- `Rng.chooseWeightedPtrArrayChecked`;
- `Rng.chooseWeightedPtrArrayCheckedFrom`.

The index helpers return `[N]usize`, compact index helpers return `[N]u32`,
value helpers return `[N]T`, const-pointer helpers return `[N]*const T`, and
mutable-pointer helpers return `[N]*T`.

Focused tests verify:

- facade and direct-source arrays preserve canonical checked/fill stream shape
  for weighted index/u32-index/value/const-pointer/mutable-pointer arrays;
- zero-length checked arrays return before validating or drawing;
- all-zero optional arrays return `null` without drawing;
- checked all-zero/empty inputs return `error.EmptyRange` without drawing;
- invalid weights and length mismatches are rejected without drawing;
- single-positive weights fill deterministic arrays without consuming the
  random stream.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `Rng weighted index array`,
  `Rng weighted u32 index array`, `Rng weighted value array`,
  `Rng weighted const ptr array`, and `Rng weighted mut ptr array` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the repeated weighted fixed-array semantics.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "checked weighted sampling preserves valid-parameter stream shape"`
- `zig test src/root.zig --test-filter "single-positive weighted index does not consume random stream"`
- `zig test src/root.zig --test-filter "invalid facade weighted helpers do not consume random stream"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked direct `Rng` weighted stack-output ergonomics
gap only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
