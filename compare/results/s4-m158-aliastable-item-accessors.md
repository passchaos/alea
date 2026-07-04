# S4-M158 AliasTable Item Accessors

Result: passed.

Purpose: add static `AliasTable` construction and update from item-derived
weight accessors. `WeightedChoice.initBy` / `updateBy` and dynamic
`WeightedTree.initBy` / `updateAllBy` already supported this shape. Direct
`AliasTable` users still needed to materialize a parallel weight slice before
building or refreshing a static alias table from item records.

## Local Rust Reference

Audited local Rust evidence:

- cached local `rand_distr 0.6.0` exposes `weighted::WeightedAliasIndex` as a
  static alias-table weighted-index sampler;
- `/home/passchaos/Work/rand/src/seq/slice.rs` exposes item-derived weight
  closures for `choose_weighted` and repeated weighted choice workflows;
- Alea reusable `WeightedChoice` and dynamic weighted trees already expose
  item-weight accessor construction/update.

This milestone removes the temporary user-owned weight-slice step for direct
`AliasTable` users whose static weights live in item records.

## Alea API Added

`src/distributions.zig` now exposes:

- `AliasTable.initBy`;
- `AliasTable.updateBy`.

Both helpers materialize temporary weights internally, then reuse the canonical
alias-table build/update path. `updateBy` requires the item slice length to
match the table length and preserves the previous table on length mismatch,
invalid weights, or allocation failure.

Focused tests verify:

- `initBy` reconstructs the same weights and total as canonical construction;
- samples exclude zero-weight items and include positive items under a
  deterministic seed;
- `updateBy` refreshes the table and preserves `constantIndex` behavior;
- invalid item-weight construction and update failures report `InvalidWeight`;
- mismatched-length updates report `InvalidParameter`;
- failed invalid updates preserve the previous table;
- allocation failure during `initBy` is reported and cleaned up.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `alias initBy/updateBy labels`.
- `tools/examplecheck.zig` verifies that example token.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe static alias-table item accessor construction/update.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "alias table item accessors"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked static weighted-sampler ergonomics gap only.
It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
