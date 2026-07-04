# S4-M148 Weighted Tree Item Accessors

Result: passed.

Purpose: build and fully refresh dynamic weighted trees from item-derived
weight accessors. S4-M121 added this ergonomics shape to reusable static
`WeightedChoice`, and S4-M147 added index-weight accessors to dynamic trees.
This milestone brings item accessor construction/update directly to
`WeightedTree` / `WeightedIntTree` for users whose dynamic weights live inside
records.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/slice.rs` exposes
  `choose_weighted`, `choose_weighted_iter`, and `sample_weighted` forms where
  the caller maps each item to a weight.
- `/home/passchaos/Work/rand/src/seq/index.rs` exposes
  `sample_weighted(rng, length, |index| ..., amount)` for index-derived
  no-replacement workflows.
- cached local `rand_distr 0.6.0` exposes
  `weighted::WeightedTreeIndex`, which builds dynamic weighted trees from
  supplied weights and supports `update`, `push`, `pop`, and `try_sample`.

Alea already covered dynamic tree operation from parallel weight slices and
from index-derived weights. The remaining ergonomic gap was avoiding a temporary
parallel weight slice when weights are fields or methods on item records.

## Alea API Added

`src/distributions.zig` now exposes:

- `WeightedTree.initBy`;
- `WeightedTree.updateAllBy`;
- `WeightedIntTree.initBy`;
- `WeightedIntTree.updateAllBy`.

`initBy(allocator, T, items, weightFn)` builds tree storage by calling
`weightFn(*const T)` once for each item. `updateAllBy(T, items, weightFn)`
requires the same length as the current tree, rebuilds a replacement tree, and
swaps only after construction succeeds. Failed refreshes from invalid weights,
integer overflow, length mismatch, or allocation failure preserve the previous
tree totals and weights.

Focused tests verify:

- generic `WeightedTree(f64)` item-accessor construction and full refresh;
- unsigned `WeightedIntTree(u32)` item-accessor construction and full refresh;
- reconstructed per-index weights, totals, and sampled indexes;
- invalid item-accessor initialization paths;
- failed invalid, mismatched-length, overflow, and allocation-failure full
  refreshes preserve existing tree state.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints
  `item-weighted tree sample labels` and
  `item-weighted int tree sample labels` rows, and the summary now calls out
  `WeightedTree` / `WeightedIntTree` `initBy` / `updateAllBy`.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe dynamic tree item-accessor construction and full refresh.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "weighted tree item accessor"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked weighted dynamic-sampler ergonomics gap only.
It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
