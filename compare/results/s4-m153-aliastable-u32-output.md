# S4-M153 AliasTable u32 Output

Result: passed.

Purpose: add compact `u32` index output to static alias tables. Alea already
had compact `u32` weighted-index output for one-shot and sequence-level
workflows, plus S4-M149 added compact output to dynamic weighted trees. Static
`AliasTable` still returned only `usize` indexes directly, requiring callers to
cast after repeated O(1) alias-table sampling.

## Local Rust Reference

Audited local Rust evidence:

- cached local `rand_distr 0.6.0` exposes `weighted::WeightedAliasIndex` as a
  static alias-table weighted-index sampler returning indexes;
- `/home/passchaos/Work/rand/src/seq/slice.rs` maps weighted indexes back to
  slice items for weighted choice workflows;
- Alea sequence APIs already expose `weightedIndexU32*` and
  `WeightedChoice.sampleIndexU32*` / `fillIndicesU32*` compact output.

This milestone extends the same compact-index ergonomics to the lower-level
static `AliasTable` sampler while keeping canonical `usize` output unchanged.

## Alea API Added

`src/distributions.zig` now exposes:

- `AliasTable.sampleU32`;
- `AliasTable.sampleU32Checked`;
- `AliasTable.sampleU32From`;
- `AliasTable.sampleU32CheckedFrom`;
- `AliasTable.fillU32`;
- `AliasTable.fillU32Checked`;
- `AliasTable.fillU32From`;
- `AliasTable.fillU32CheckedFrom`.

Checked `u32` helpers reject populations longer than `std.math.maxInt(u32)`.
They otherwise mirror the existing `usize` alias-table sample/fill helpers and
preserve deterministic `constantIndex` fast paths.

Focused tests verify:

- `sampleU32From` matches canonical `sampleFrom` under identical seeds after
  casting;
- `fillU32CheckedFrom` matches canonical `fillFrom` under identical seeds after
  casting;
- facade and direct-source checked paths preserve stream shape;
- zero-length compact fills return without consuming the stream;
- single-positive alias tables return compact indexes without consuming the
  stream.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `alias u32 sample indices`.
- `tools/examplecheck.zig` verifies that example token.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe compact static alias-table index output.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "alias table u32"`
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
