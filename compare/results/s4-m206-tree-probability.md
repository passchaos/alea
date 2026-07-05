# S4-M206 Dynamic Tree Optional Probability Lookup

Result: passed.

Purpose: add optional single-probability lookup to dynamic weighted trees. Alea
already exposed checked `probabilityAt` plus bulk `probabilities` /
`probabilitiesInto`; S4-M206 adds null-on-missing `probability(index)` helpers
matching the optional lookup style of `AliasTable.probability` and
`WeightedChoice.probability`.

## Local Reference

Local Rust `rand` exposes optional single-weight lookup on static
`WeightedIndex::weight`; Alea additionally exposes probability diagnostics for
its weighted samplers. This milestone keeps static and dynamic weighted sampler
probability diagnostics consistent in Zig.

Relevant local Rust source:

- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs`

## Alea API Added

`src/distributions.zig` now exposes:

- `WeightedTree.probability`;
- `WeightedIntTree.probability`.

Semantics:

- returns `?f64`;
- valid indexes mirror `probabilityAt(index)`;
- out-of-range indexes return `null`;
- invalid totals return `null`;
- existing checked `probabilityAt`, optional `weight`, bulk probability exports,
  update, push/pop, and sampling behavior are preserved.

Focused tests verify in-range probabilities and out-of-range `null` behavior
for both dynamic tree families.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints dynamic and integer tree
  `probability(...)=... missing=true` rows.
- `tools/examplecheck.zig` verifies those example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe optional dynamic-tree probability lookup.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M207.

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
