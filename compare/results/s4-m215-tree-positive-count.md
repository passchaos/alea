# S4-M215 Dynamic Tree Positive-Count Diagnostics

Result: passed.

Purpose: add `WeightedTree.positiveCount()` and `WeightedIntTree.positiveCount()`
as diagnostics for the number of currently positive-weight choices in mutable
weighted trees. Dynamic trees already maintain this count internally to support
`constantIndex()` and single-positive no-consume sampling paths; S4-M215 exposes
it directly for callers and tooling.

## Local Reference

Local Rust `rand` exposes reusable weighted diagnostics such as
`WeightedIndex::weight`, `WeightedIndex::weights`, and `WeightedIndex::total_weight`.
Alea's dynamic `WeightedTree` and `WeightedIntTree` are Zig-native mutable
weighted samplers, so `positiveCount()` is a Zig-native diagnostic that goes
beyond the Rust baseline rather than a direct trait/API port.

Relevant local Rust source:

- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs`

## Alea API Added

`src/distributions.zig` now exposes:

- `WeightedTree.positiveCount`;
- `WeightedIntTree.positiveCount`.

Semantics:

- returns `usize`;
- returns the number of entries whose current weight is positive;
- tracks `init`, `initBy`, `initByIndex`, `update`, `updateAll`, `updateAllBy`,
  `updateAllByIndex`, `push`, and `pop` through the existing maintained state;
- does not allocate;
- does not consume randomness;
- complements `constantIndex()` by distinguishing zero, one, and many
  positive-weight choices.

Focused tests verify positive-count transitions for both generic and integer
trees across initialization, invalid/all-zero state, push, update, pop, and empty
push/pop workflows.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `dynamic tree positiveCount: ...` and
  `integer tree positiveCount: ...`.
- `tools/examplecheck.zig` verifies those example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the diagnostics.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M216.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "weighted tree supports dynamic updates"`
- `zig test src/root.zig --test-filter "weighted int tree supports dynamic updates"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked dynamic weighted-sampler diagnostics gap only.
It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
