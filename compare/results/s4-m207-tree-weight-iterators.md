# S4-M207 Dynamic Tree Weight Iterators

Result: passed.

Purpose: add lazy weight iterators to dynamic weighted trees. Alea already
exposed static `AliasTable.weightIter` and `WeightedChoice.weightIter`, plus
dynamic tree `weights` / `weightsInto` bulk exports. S4-M207 adds allocation-free
dynamic weight iteration for update-heavy samplers.

## Local Reference

Local Rust `rand` exposes `WeightedIndex::weights()` as a lazy iterator for
static weighted samplers. Alea's `WeightedTree` / `WeightedIntTree` target
dynamic update workloads, but the same lazy diagnostic shape is useful for
caller-owned, allocation-free inspection.

Relevant local Rust source:

- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs`

## Alea API Added

`src/distributions.zig` now exposes:

- `WeightedTree.WeightIterator`;
- `WeightedTree.weightIter`;
- `WeightedTree.WeightIterator.next`;
- `WeightedTree.WeightIterator.remaining`;
- `WeightedTree.WeightIterator.len`;
- `WeightedTree.WeightIterator.sizeHint`;
- `WeightedTree.WeightIterator.fill`;
- `WeightedIntTree.WeightIterator`;
- `WeightedIntTree.weightIter`;
- `WeightedIntTree.WeightIterator.next`;
- `WeightedIntTree.WeightIterator.remaining`;
- `WeightedIntTree.WeightIterator.len`;
- `WeightedIntTree.WeightIterator.sizeHint`;
- `WeightedIntTree.WeightIterator.fill`.

Semantics:

- streams current dynamic weights in index order;
- `next()` returns `null` after the final weight;
- `remaining()`, `len()`, and `sizeHint()` report exact remaining counts;
- `fill()` drains up to the destination length and returns the filled count;
- preserves existing optional `weight`, checked `weightAt`, bulk exports,
  update, push/pop, and sampling behavior.

Focused tests verify `next`, `remaining`, `len`, exact size hints, caller-buffer
`fill`, and exhaustion for both dynamic tree families.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints dynamic and integer tree
  `weightIter fill` and `weightIter sizeHint` rows.
- `tools/examplecheck.zig` verifies those example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe dynamic weight iterators.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M208.

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
