# S4-M220 Dynamic Tree Ordered Partial Updates

Result: passed.

Purpose: add ordered partial-update helpers to dynamic weighted trees. Alea
already had dynamic `WeightedTree.update(index, weight)` and
`WeightedIntTree.update(index, weight)` for O(log n) single updates plus
S4-M219 static/reusable `updateMany` helpers. S4-M220 aligns the dynamic tree
surface with the static partial-update ergonomics while preserving the tree
samplers' dynamic update/push/pop role.

## Local Reference

Local Rust `WeightedIndex::update_weights` validates an ordered partial-update
list before mutating, while `rand_distr` recommends dynamic weighted trees when
frequent updates are needed. Alea's dynamic trees are Zig-native equivalents for
that frequent-update use case, so `updateMany` brings the ordered partial-update
workflow to the dynamic tree APIs without changing existing `update` single-index
or `updateAll` full-refresh methods.

Relevant local Rust source:

- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs`

## Alea API Added

`src/distributions.zig` now exposes:

- `WeightedTree.Update`;
- `WeightedTree.updateMany`;
- `WeightedIntTree.Update`;
- `WeightedIntTree.updateMany`.

Semantics:

- empty update lists are a no-op;
- update indexes must be in bounds and strictly increasing;
- duplicate or unordered indexes return `error.InvalidParameter`;
- invalid floating weights, non-finite totals, unsigned weights wider than the
  `u64` accumulator, and unsigned accumulator overflow return
  `error.InvalidWeight` before changing tree state;
- zero-total states are allowed for dynamic trees, matching existing single
  `update` semantics, and sampling/probability calls continue to report
  `error.InvalidWeight` until a positive weight is restored;
- successful updates refresh `totalWeight`, `positiveCount`, `constantIndex`,
  `weight` / `weights`, `probability`, and iterator diagnostics.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `dynamic tree updateMany totalWeight:
  ...` and `integer tree updateMany totalWeight: ...`.
- `tools/examplecheck.zig` verifies those example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe dynamic-tree ordered partial updates.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M221.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "weighted tree updateMany"`
- `zig test src/root.zig --test-filter "weighted int tree updateMany"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build statcheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked dynamic weighted-tree partial-update
ergonomics gap only. It does not resolve S4-M11's exact/default-compatible dense
SIMD normal/exponential blocker, does not add a new architecture/runtime runner,
and is not whole-goal completion evidence.
