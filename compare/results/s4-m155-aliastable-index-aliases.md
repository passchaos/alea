# S4-M155 AliasTable Index Aliases

Result: passed.

Purpose: add index-named aliases to static alias tables. `AliasTable` samples
indexes directly, while `WeightedChoice` and dynamic weighted trees now expose
explicit `sampleIndex*` / `fillIndices*` names. This milestone makes the
lower-level static alias-table sampler equally discoverable for users searching
for index-oriented APIs.

## Local Rust Reference

Audited local Rust evidence:

- cached local `rand_distr 0.6.0` exposes `weighted::WeightedAliasIndex` as a
  static weighted-index sampler;
- `/home/passchaos/Work/rand/src/seq/slice.rs` maps weighted index samplers back
  to items for weighted choice workflows;
- Alea `WeightedChoice` and dynamic weighted trees already expose explicit
  index-named sample/fill helpers.

This milestone is a naming/discoverability improvement: the alias-table
algorithm and canonical `sample` / `fill` APIs remain unchanged.

## Alea API Added

`src/distributions.zig` now exposes:

- `AliasTable.sampleIndex`;
- `AliasTable.sampleIndexFrom`;
- `AliasTable.sampleIndexU32`;
- `AliasTable.sampleIndexU32Checked`;
- `AliasTable.sampleIndexU32From`;
- `AliasTable.sampleIndexU32CheckedFrom`;
- `AliasTable.fillIndices`;
- `AliasTable.fillIndicesFrom`;
- `AliasTable.fillIndicesU32`;
- `AliasTable.fillIndicesU32Checked`;
- `AliasTable.fillIndicesU32From`;
- `AliasTable.fillIndicesU32CheckedFrom`.

The aliases forward to existing `sample*`, `sampleU32*`, `fill*`, and
`fillU32*` implementations, preserving stream shape, population-size checks,
and deterministic `constantIndex` no-consume behavior.

Focused tests verify:

- `sampleIndexFrom` matches `sampleFrom` under identical seeds;
- `sampleIndexU32From` / checked facade helpers match canonical compact output;
- `fillIndicesFrom` and `fillIndicesU32CheckedFrom` match canonical fill paths
  under identical seeds;
- single-positive alias-table aliases return deterministic indexes without
  consuming the random stream.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `alias sampleIndex alias`.
- `tools/examplecheck.zig` verifies that example token.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe static alias-table index aliases.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "alias table index aliases"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked static weighted-sampler discoverability gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
