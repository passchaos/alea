# S4-M151 Weighted Tree Index Aliases

Result: passed.

Purpose: add index-named aliases to dynamic weighted trees. `WeightedChoice`
already exposes `sampleIndex*` and `fillIndices*` APIs because it samples items
and indexes. `WeightedTree` / `WeightedIntTree` only sample indexes, but users
moving from `WeightedChoice` or sequence weighted-index helpers benefit from the
same naming.

## Local Rust Reference

Audited local Rust evidence:

- cached local `rand_distr 0.6.0` exposes `weighted::WeightedTreeIndex`, whose
  samples are indexes;
- `/home/passchaos/Work/rand/src/seq/slice.rs` maps weighted index samplers back
  to items for `choose_weighted` / repeated weighted item workflows;
- Alea reusable `WeightedChoice` already uses explicit `sampleIndex*`,
  `fillIndices*`, and `indices*` names beside value/pointer workflows.

This milestone is a Zig-native discoverability improvement rather than a new
algorithm: dynamic tree sampling remains index sampling, and the aliases make
that explicit without changing stream shape.

## Alea API Added

`src/distributions.zig` now exposes for both `WeightedTree(Weight)` and
`WeightedIntTree(Weight)`:

- `sampleIndex`;
- `sampleIndexChecked`;
- `sampleIndexFrom`;
- `sampleIndexCheckedFrom`;
- `sampleIndexU32`;
- `sampleIndexU32Checked`;
- `sampleIndexU32From`;
- `sampleIndexU32CheckedFrom`;
- `fillIndices`;
- `fillIndicesChecked`;
- `fillIndicesFrom`;
- `fillIndicesCheckedFrom`;
- `fillIndicesU32`;
- `fillIndicesU32Checked`;
- `fillIndicesU32From`;
- `fillIndicesU32CheckedFrom`.

The aliases forward to existing `sample*`, `sampleU32*`, `fill*`, and
`fillU32*` implementations, preserving stream shape, single-positive
no-consume behavior, population-size checks, and checked invalid-weight errors.

Focused tests verify:

- generic `WeightedTree(f64)` aliases match the canonical sample/fill helpers
  under identical seeds;
- unsigned `WeightedIntTree(u32)` aliases match the canonical sample/fill
  helpers under identical seeds;
- facade and direct-source alias paths preserve stream shape;
- checked aliases report the same invalid all-zero tree errors;
- single-positive alias paths do not consume the random stream.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `dynamic tree sampleIndex alias` and
  `integer tree fillIndices alias`.
- `tools/examplecheck.zig` verifies those tokens and the
  `sampleIndex/fillIndices` summary token.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe dynamic-tree index aliases.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "weighted tree index aliases"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked weighted dynamic-tree discoverability gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
