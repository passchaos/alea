# S4-M216 AliasTable Positive-Count Diagnostics

Result: passed.

Purpose: add `AliasTable.positiveCount()` as a static weighted-sampler diagnostic
for the number of positive-weight choices captured by the alias table.
`AliasTable` already computed this count while deriving `constantIndex()` during
initialization and update; S4-M216 stores and exposes it directly, aligning
static alias-table diagnostics with dynamic tree `positiveCount()`.

## Local Reference

Local Rust `rand` exposes reusable weighted diagnostics such as
`WeightedIndex::weight`, `WeightedIndex::weights`, and `WeightedIndex::total_weight`.
Alea's `AliasTable` is its Zig-native static alias-table sampler, so
`positiveCount()` is a Zig-native diagnostic that goes beyond the Rust baseline
rather than a direct trait/API port.

Relevant local Rust source:

- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs`

## Alea API Added

`src/distributions.zig` now exposes:

- `AliasTable.positiveCount`.

Semantics:

- returns `usize`;
- returns the number of entries whose input weight is positive;
- updates when `update`, `updateBy`, or `updateByIndex` rebuilds the table;
- does not allocate;
- does not consume randomness;
- complements `constantIndex()` by distinguishing one positive choice from many.

Focused tests verify that `positiveCount()` matches reconstructed weights and
that it refreshes through existing update paths.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `alias positiveCount: ...`.
- `tools/examplecheck.zig` verifies that example source token.
- `docs/api-reference.md` lists the new public symbol.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the diagnostic.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M217.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "alias table exposes totals"`
- `zig test src/root.zig --test-filter "alias table item accessors initialize and refresh tables"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked static weighted-sampler diagnostics gap only.
It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
