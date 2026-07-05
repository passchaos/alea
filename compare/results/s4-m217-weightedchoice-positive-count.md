# S4-M217 WeightedChoice Positive-Count Diagnostics

Result: passed.

Purpose: add `WeightedChoice.positiveCount()` as a reusable weighted-choice
diagnostic for the number of positive-weight choices. `WeightedChoice` already
wraps `AliasTable`; S4-M217 exposes the underlying alias table's positive-count
state directly on the reusable item sampler.

## Local Reference

Local Rust `rand` exposes reusable weighted diagnostics such as
`WeightedIndex::weight`, `WeightedIndex::weights`, and `WeightedIndex::total_weight`.
Alea's `WeightedChoice` is a Zig-native item-selection wrapper around
`AliasTable`, so `positiveCount()` is a Zig-native diagnostic that goes beyond
the Rust baseline rather than a direct trait/API port.

Relevant local Rust source:

- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs`

## Alea API Added

`src/seq.zig` now exposes:

- `WeightedChoice.positiveCount`.

Semantics:

- returns `usize`;
- returns the number of positive-weight choices in the underlying alias table;
- updates when `update`, `updateBy`, or `updateByIndex` rebuilds the table;
- does not allocate;
- does not consume randomness;
- complements `constantIndex()` by distinguishing one positive choice from many.

Focused tests verify multi-positive and single-positive states plus update
transitions.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `WeightedChoice.positiveCount: ...`.
- `tools/examplecheck.zig` verifies that example source token.
- `docs/api-reference.md` lists the new public symbol.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the diagnostic.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M218.

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
