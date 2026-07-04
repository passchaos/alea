# S4-M160 Weighted Tree Index Arrays

Result: passed.

Purpose: add fixed-size repeated index arrays to dynamic weighted trees.
Static `AliasTable` gained fixed-size arrays in S4-M159, and sequence weighted
workflows already expose `sampleWeightedIndexArray*`. Dynamic `WeightedTree` /
`WeightedIntTree` still required caller-owned slices, owned heap batches, or
iterators for repeated with-replacement index samples.

## Local Rust Reference

Audited local Rust evidence:

- cached local `rand_distr 0.6.0` exposes `weighted::WeightedTreeIndex` as a
  dynamic weighted-index sampler;
- `/home/passchaos/Work/rand/src/seq/slice.rs` maps weighted index samplers back
  to items for weighted choice workflows;
- Alea `seq.sampleWeightedIndexArray*` already provides fixed-size weighted
  index arrays at the sequence layer.

This milestone brings equivalent fixed-size ergonomics to dynamic weighted-tree
samplers without requiring heap allocation or caller-managed slice buffers.

## Alea API Added

`src/distributions.zig` now exposes for both `WeightedTree(Weight)` and
`WeightedIntTree(Weight)`:

- `indexArray`;
- `indexArrayFrom`;
- `indexArrayChecked`;
- `indexArrayCheckedFrom`;
- `indexArrayU32`;
- `indexArrayU32Checked`;
- `indexArrayU32From`;
- `indexArrayU32CheckedFrom`.

The `usize` helpers return `[N]usize`. The compact `u32` helpers return
`[N]u32` for populations that fit `u32`, inheriting validation from
`fillU32CheckedFrom`. Checked `usize` helpers report invalid all-zero trees
instead of trapping through unchecked sampling.

Focused tests verify:

- generic `WeightedTree(f64)` fixed `usize` arrays match caller-owned
  `fillFrom` under identical seeds;
- generic `WeightedTree(f64)` fixed `u32` arrays match caller-owned
  `fillU32CheckedFrom` under identical seeds;
- facade and direct-source paths preserve stream shape;
- zero-length fixed arrays return without sampling;
- unsigned `WeightedIntTree(u32)` fixed `usize` and `u32` arrays match canonical
  fills under identical seeds;
- single-positive integer trees return deterministic arrays without consuming
  the random stream;
- invalid all-zero trees report `InvalidWeight` from checked fixed arrays.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `dynamic tree u32 index array` and
  `integer tree u32 index array`.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe fixed-size dynamic-tree index arrays.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "weighted tree fixed index arrays"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked dynamic weighted-sampler stack-output
ergonomics gap only. It does not resolve S4-M11's exact/default-compatible dense
SIMD normal/exponential blocker, does not add a new architecture/runtime runner,
and is not whole-goal completion evidence.
