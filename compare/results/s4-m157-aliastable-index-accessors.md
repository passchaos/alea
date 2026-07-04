# S4-M157 AliasTable Index Accessors

Result: passed.

Purpose: add static `AliasTable` construction and update from comptime
index-weight functions. `WeightedChoice.initByIndex` / `updateByIndex` and
dynamic `WeightedTree.initByIndex` / `updateAllByIndex` already supported this
shape. Direct `AliasTable` users still needed to materialize a parallel weight
slice before building or refreshing a static alias table.

## Local Rust Reference

Audited local Rust evidence:

- cached local `rand_distr 0.6.0` exposes `weighted::WeightedAliasIndex` as a
  static alias-table weighted-index sampler;
- `/home/passchaos/Work/rand/src/seq/index.rs` exposes length/index-weight
  closure workflows via `sample_weighted`;
- Alea reusable `WeightedChoice` and dynamic weighted trees already expose
  index-weight accessor construction/update.

This milestone removes the temporary user-owned weight-slice step for direct
`AliasTable` users whose static weights are naturally functions of indexes.

## Alea API Added

`src/distributions.zig` now exposes:

- `AliasTable.initByIndex`;
- `AliasTable.updateByIndex`.

Both helpers materialize temporary weights internally, then reuse the canonical
alias-table build/update path. Failed `updateByIndex` calls preserve the
previous table because `AliasTable.update` builds a replacement table before
swapping.

Focused tests verify:

- `initByIndex` reconstructs the same weights and total as canonical
  construction;
- samples exclude zero-weight indexes and include positive indexes under a
  deterministic seed;
- `updateByIndex` refreshes the table and preserves `constantIndex` behavior;
- invalid index-weight construction and update failures report `InvalidWeight`;
- failed invalid updates preserve the previous table;
- allocation failure during `initByIndex` is reported and cleaned up.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints
  `alias initByIndex/updateByIndex indices`.
- `tools/examplecheck.zig` verifies that example token.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe static alias-table index accessor construction/update.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "alias table index accessors"`
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
