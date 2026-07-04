# S4-M159 AliasTable Index Arrays

Result: passed.

Purpose: add fixed-size repeated index arrays to static alias tables. Sequence
weighted-index workflows already expose fixed-size array helpers, and direct
`AliasTable` now has single-sample, caller-owned fill, owned batch, alias, and
iterator APIs. This milestone adds stack-friendly fixed-size array output for
direct alias-table repeated samples.

## Local Rust Reference

Audited local Rust evidence:

- cached local `rand_distr 0.6.0` exposes `weighted::WeightedAliasIndex` as a
  static alias-table weighted-index sampler;
- `/home/passchaos/Work/rand/src/seq/slice.rs` maps weighted index samplers back
  to items for weighted choice workflows;
- Alea `seq.sampleWeightedIndexArray*` already provides fixed-size weighted
  index arrays at the sequence layer.

This milestone brings equivalent fixed-size ergonomics to the reusable
`AliasTable` sampler without requiring heap allocation or caller-managed slice
buffers.

## Alea API Added

`src/distributions.zig` now exposes:

- `AliasTable.indexArray`;
- `AliasTable.indexArrayFrom`;
- `AliasTable.indexArrayU32`;
- `AliasTable.indexArrayU32Checked`;
- `AliasTable.indexArrayU32From`;
- `AliasTable.indexArrayU32CheckedFrom`.

The `usize` helpers return `[N]usize`. The compact `u32` helpers return `[N]u32`
for populations that fit `u32`, inheriting the same validation as
`fillU32CheckedFrom`.

Focused tests verify:

- fixed `usize` arrays match caller-owned `fillFrom` under identical seeds;
- fixed `u32` arrays match caller-owned `fillU32CheckedFrom` under identical
  seeds;
- facade and direct-source paths preserve stream shape;
- zero-length fixed arrays return without sampling;
- single-positive alias tables return deterministic arrays without consuming the
  random stream.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `alias u32 index array`.
- `tools/examplecheck.zig` verifies that example token.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe fixed-size static alias-table index arrays.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "alias table fixed index arrays"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked static weighted-sampler stack-output
ergonomics gap only. It does not resolve S4-M11's exact/default-compatible dense
SIMD normal/exponential blocker, does not add a new architecture/runtime runner,
and is not whole-goal completion evidence.
