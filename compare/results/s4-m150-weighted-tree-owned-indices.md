# S4-M150 Weighted Tree Owned Indices

Result: passed.

Purpose: add allocation-returning repeated index batches to dynamic weighted
trees. Earlier milestones added caller-owned `fill` / `fillU32` paths for
dynamic `WeightedTree` / `WeightedIntTree`; reusable `WeightedChoice` already
had owned `indices` / `indicesU32` helpers. This milestone brings the same
owned repeated-sample ergonomics to dynamic tree workflows.

## Local Rust Reference

Audited local Rust evidence:

- cached local `rand_distr 0.6.0` exposes `weighted::WeightedTreeIndex` for
  dynamic weighted-index sampling;
- `/home/passchaos/Work/rand/src/seq/slice.rs` exposes repeated weighted draws
  via iterator forms such as `choose_weighted_iter`;
- `/home/passchaos/Work/rand/src/seq/index.rs` exposes allocation-returning
  weighted index sample structures for no-replacement workflows.

Alea already has caller-owned dynamic tree fills and allocation-returning
weighted index batches elsewhere. This milestone removes the caller-buffer
requirement for repeated dynamic-tree samples while keeping checked variants for
invalid/all-zero trees.

## Alea API Added

`src/distributions.zig` now exposes for both `WeightedTree(Weight)` and
`WeightedIntTree(Weight)`:

- `indices`;
- `indicesFrom`;
- `indicesChecked`;
- `indicesCheckedFrom`;
- `indicesU32`;
- `indicesU32From`;
- `indicesU32Checked`;
- `indicesU32CheckedFrom`.

The unchecked owned helpers mirror unchecked fills. The checked helpers allocate
the output slice, fill it through the checked caller-owned APIs, and free the
allocation on validation or sampling failure. `indicesU32*` returns compact
`u32` batches and inherits the checked population-size validation from
`fillU32CheckedFrom`.

Focused tests verify:

- generic `WeightedTree(f64)` owned `usize` and `u32` batches match caller-owned
  fills under the same seeds;
- unsigned `WeightedIntTree(u32)` owned `usize` and `u32` batches match
  caller-owned fills under the same seeds;
- facade/direct owned batch paths work;
- zero-count owned checked batches allocate empty slices without sampling;
- allocation failures are reported and cleaned up;
- invalid all-zero trees free staged owned buffers and return `InvalidWeight`;
- single-positive owned batches return deterministic indexes without consuming
  the random stream.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `dynamic tree owned indices` and
  `integer tree owned u32 indices`.
- `tools/examplecheck.zig` verifies those tokens and the
  `owned indices/indicesU32` summary token.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe owned dynamic-tree index batches.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "weighted tree owned index batches"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked weighted dynamic-tree ergonomics gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
