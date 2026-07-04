# S4-M154 AliasTable Owned Indices

Result: passed.

Purpose: add allocation-returning repeated index batches to static alias tables.
S4-M153 added compact `u32` caller-owned output to `AliasTable`; reusable
`WeightedChoice` and dynamic weighted trees already had owned repeated index
batches. This milestone brings the same owned repeated-sample ergonomics to the
lower-level static alias-table sampler.

## Local Rust Reference

Audited local Rust evidence:

- cached local `rand_distr 0.6.0` exposes `weighted::WeightedAliasIndex` as a
  static alias-table weighted-index sampler;
- `/home/passchaos/Work/rand/src/seq/slice.rs` maps weighted index samplers back
  to items for repeated weighted choice workflows;
- Alea reusable `WeightedChoice.indices*` and sequence `weightedIndex*Batch*`
  already expose allocation-returning repeated weighted-index outputs.

This milestone closes the direct `AliasTable` owned-batch gap without changing
the canonical caller-owned `fill` / `fillU32` or single-sample APIs.

## Alea API Added

`src/distributions.zig` now exposes:

- `AliasTable.indices`;
- `AliasTable.indicesFrom`;
- `AliasTable.indicesU32`;
- `AliasTable.indicesU32From`.

The owned helpers allocate output, fill through the existing `fillFrom` /
`fillU32CheckedFrom` paths, and free on allocation failure via normal Zig error
unwinding. `indicesU32*` inherits population-size validation from the compact
`u32` fill path.

Focused tests verify:

- owned `usize` batches match caller-owned `fillFrom` under identical seeds;
- owned `u32` batches match caller-owned `fillU32CheckedFrom` under identical
  seeds;
- facade and direct-source owned batch paths preserve stream shape;
- zero-count owned batches allocate empty slices;
- allocation failures are reported;
- single-positive alias tables allocate deterministic batches without consuming
  the random stream.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `alias owned u32 indices`.
- `tools/examplecheck.zig` verifies that example token.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe owned static alias-table index batches.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "alias table owned"`
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
