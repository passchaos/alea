# S4-M147 Weighted Tree Index Accessors

Result: passed.

Purpose: build and fully refresh dynamic weighted trees from comptime
index-weight functions. S4-M146 added the same construction/update ergonomics to
static `WeightedChoice`; this milestone brings length/index-weight accessors to
the dynamic `WeightedTree` / `WeightedIntTree` families used for frequent
update/push/pop/sample workloads.

## Local Rust Reference

Audited `/home/passchaos/Work/rand` and local `rand_distr` evidence:

- `rand_distr::weighted::WeightedTreeIndex` provides dynamic weighted
  update+sample workflows;
- `rand::seq::index::sample_weighted(rng, length, |index| ..., amount)`
  demonstrates the length/index-weight accessor shape.

Alea already supports dynamic weighted trees from parallel weight slices. This
milestone removes that intermediate slice for users whose dynamic weights are
naturally functions of positions.

## Alea API Added

`src/distributions.zig` now exposes:

- `WeightedTree.initByIndex`;
- `WeightedTree.updateAll`;
- `WeightedTree.updateAllByIndex`;
- `WeightedIntTree.initByIndex`;
- `WeightedIntTree.updateAll`;
- `WeightedIntTree.updateAllByIndex`.

`initByIndex` builds tree storage from `0..length`. `updateAll` and
`updateAllByIndex` rebuild replacement trees and swap only after construction
succeeds, preserving the previous tree on invalid weights, overflowing totals,
or allocation failure. The existing single-index `update`, `push`, `pop`,
`sample`, `fill`, and diagnostics APIs continue to operate on the same tree
shape.

Focused tests verify:

- generic `WeightedTree(f64)` index-weight construction and full refresh;
- unsigned `WeightedIntTree(u32)` index-weight construction and full refresh;
- reconstructed weights, total weights, and sampled indexes;
- invalid index-weight initialization paths;
- failed invalid and allocation-failure full refreshes preserve existing tree
  totals and weights.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `index-weighted tree sample indices`
  and `index-weighted int tree sample indices` rows.
- `tools/examplecheck.zig` verifies those example tokens and the summary token.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe dynamic tree index accessor construction and full refresh.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "weighted tree index accessor"`
- `zig build test`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked weighted sequence/dynamic-sampler ergonomics
gap only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
