# S4-M205 Dynamic Tree Optional Weight Lookup

Result: passed.

Purpose: add optional single-weight lookup to dynamic weighted trees. Alea
already exposed checked `get` / `weightAt` plus bulk `weights` /
`weightsInto`; S4-M205 adds null-on-missing `weight(index)` helpers matching
the optional lookup style of `AliasTable.weight` and `WeightedChoice.weight`.

## Local Reference

Local Rust `rand` exposes optional single-weight lookup on static
`WeightedIndex::weight`. Alea's dynamic `WeightedTree` / `WeightedIntTree`
serve a different update-heavy role, but this milestone keeps static and
dynamic weighted sampler diagnostics consistent in Zig.

Relevant local Rust source:

- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs`

## Alea API Added

`src/distributions.zig` now exposes:

- `WeightedTree.weight`;
- `WeightedIntTree.weight`.

Semantics:

- `WeightedTree.weight(index)` returns `?f64`;
- `WeightedIntTree.weight(index)` returns `?u64`;
- valid indexes mirror `weightAt(index)`;
- out-of-range indexes return `null`;
- existing checked `get` / `weightAt`, probability diagnostics, bulk exports,
  update, push/pop, and sampling behavior are preserved.

Focused tests verify in-range weights and out-of-range `null` behavior for both
dynamic tree families.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints dynamic and integer tree
  `weight(...)=... missing=true` rows.
- `tools/examplecheck.zig` verifies those example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe optional dynamic-tree weight lookup.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M206.

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

This milestone closes an unblocked dynamic-weighted-sampler diagnostics gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
