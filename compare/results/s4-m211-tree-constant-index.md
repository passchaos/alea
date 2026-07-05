# S4-M211 Dynamic Tree Constant-Index Diagnostics

Result: passed.

Purpose: add `WeightedTree.constantIndex()` and `WeightedIntTree.constantIndex()`
as diagnostics for dynamic weighted samplers' single-positive fast path. Alea
already used this state internally to make single-positive dynamic tree samples
and fills deterministic without consuming randomness; S4-M211 exposes it for
callers and tooling.

## Local Reference

Local Rust `rand` exposes reusable weighted diagnostics such as
`WeightedIndex::weight`, `WeightedIndex::weights`, and `WeightedIndex::total_weight`,
while Alea's static `AliasTable` already exposes `constantIndex()` for its
single-positive deterministic path. Dynamic `WeightedTree` and
`WeightedIntTree` are Alea's Zig-native mutable weighted samplers, so this is a
Zig-native diagnostic that goes beyond the Rust baseline rather than a direct
trait/API port.

Relevant local Rust source:

- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs`

## Alea API Added

`src/distributions.zig` now exposes:

- `WeightedTree.constantIndex`;
- `WeightedIntTree.constantIndex`.

Semantics:

- returns `?usize`;
- returns the sole positive-weight index when exactly one choice has positive
  weight;
- returns `null` for empty, all-zero, and multi-positive trees;
- tracks `update`, `updateAll`, `push`, and `pop` state;
- does not allocate;
- does not consume randomness;
- matches the deterministic no-consume sample/fill path used by both dynamic
  tree families.

Focused tests verify null / non-null transitions for both generic and integer
trees across initialization, update, push, and pop, including the existing
single-positive no-consume stream tests.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `dynamic tree constantIndex: ...`,
  `integer tree constantIndex: ...`, and single-positive refresh examples.
- `tools/examplecheck.zig` verifies the example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the constant-index diagnostics.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M212.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "weighted tree supports dynamic updates"`
- `zig test src/root.zig --test-filter "weighted int tree supports dynamic updates"`
- `zig test src/root.zig --test-filter "single-positive weighted trees do not consume random stream"`
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
