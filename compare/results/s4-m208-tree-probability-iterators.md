# S4-M208 Dynamic Tree Probability Iterators

Result: passed.

Purpose: add lazy probability iterators to dynamic weighted trees. Alea already
exposed static `AliasTable.probabilityIter` and `WeightedChoice.probabilityIter`,
plus dynamic tree `probabilities` / `probabilitiesInto` bulk exports. S4-M208
adds allocation-free dynamic probability iteration for update-heavy samplers.

## Local Reference

Local Rust `rand` exposes lazy weighted sampler diagnostics such as
`WeightedIndex::weights()`. Alea additionally exposes probability diagnostics,
and this milestone keeps dynamic `WeightedTree` / `WeightedIntTree` aligned with
the static weighted sampler probability-iterator surface.

Relevant local Rust source:

- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs`

## Alea API Added

`src/distributions.zig` now exposes:

- `WeightedTree.ProbabilityIterator`;
- `WeightedTree.probabilityIter`;
- `WeightedTree.ProbabilityIterator.next`;
- `WeightedTree.ProbabilityIterator.remaining`;
- `WeightedTree.ProbabilityIterator.len`;
- `WeightedTree.ProbabilityIterator.sizeHint`;
- `WeightedTree.ProbabilityIterator.fill`;
- `WeightedIntTree.ProbabilityIterator`;
- `WeightedIntTree.probabilityIter`;
- `WeightedIntTree.ProbabilityIterator.next`;
- `WeightedIntTree.ProbabilityIterator.remaining`;
- `WeightedIntTree.ProbabilityIterator.len`;
- `WeightedIntTree.ProbabilityIterator.sizeHint`;
- `WeightedIntTree.ProbabilityIterator.fill`.

Semantics:

- streams current normalized probabilities in index order;
- `next()` returns `null` after the final probability or invalid totals;
- `remaining()`, `len()`, and `sizeHint()` report exact remaining counts while
  totals are valid;
- `fill()` drains up to the destination length and returns the filled count;
- preserves existing optional `probability`, checked `probabilityAt`, bulk
  exports, update, push/pop, and sampling behavior.

Focused tests verify `next`, `remaining`, `len`, exact size hints,
caller-buffer `fill`, and exhaustion for both dynamic tree families.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints dynamic and integer tree
  `probabilityIter fill` and `probabilityIter sizeHint` rows.
- `tools/examplecheck.zig` verifies those example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `docs/examples.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe dynamic probability iterators.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M209.

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
