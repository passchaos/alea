# S4-M212 WeightedChoice Constant-Index Diagnostics

Result: passed.

Purpose: add `WeightedChoice.constantIndex()` as a reusable weighted-choice
diagnostic for the single-positive fast path. `WeightedChoice` already delegates
sampling to `AliasTable`, and its fill helpers already use the underlying
`AliasTable.constantIndex()` to return deterministic values without consuming
randomness. S4-M212 exposes that index directly.

## Local Reference

Local Rust `rand` exposes reusable weighted diagnostics such as
`WeightedIndex::weight`, `WeightedIndex::weights`, and `WeightedIndex::total_weight`.
Alea's static `AliasTable` also exposes `constantIndex()`, and `WeightedChoice`
wraps that table for item selection. `WeightedChoice.constantIndex()` is a
Zig-native adoption/diagnostic affordance that goes beyond the Rust baseline
rather than copying a Rust trait shape.

Relevant local Rust source:

- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs`

## Alea API Added

`src/seq.zig` now exposes:

- `WeightedChoice.constantIndex`.

Semantics:

- returns `?usize`;
- returns the sole positive-weight item index when exactly one choice has
  positive weight;
- returns `null` for multi-positive weighted choices;
- tracks `update`, `updateBy`, and `updateByIndex` through the underlying alias
  table state;
- does not allocate;
- does not consume randomness;
- matches the deterministic no-consume sample/fill path used by
  `WeightedChoice`.

Focused tests verify multi-positive `null`, single-positive index reporting,
and update transitions from single-positive to multi-positive and back.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `WeightedChoice.constantIndex: ...`
  and `WeightedChoice.single-positive constantIndex: ...`.
- `tools/examplecheck.zig` verifies those example source tokens.
- `docs/api-reference.md` lists the new public symbol.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the diagnostic.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M213.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "weighted choice sampler maps alias indexes to items"`
- `zig test src/root.zig --test-filter "single-positive weighted choice does not consume random stream"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked reusable weighted-choice diagnostics gap only.
It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
