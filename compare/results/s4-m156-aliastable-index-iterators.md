# S4-M156 AliasTable Index Iterators

Result: passed.

Purpose: add repeated with-replacement index iterators to static alias tables.
`AliasTable` already had single-sample, caller-owned fill, owned batch, compact
`u32`, and index-alias APIs. This milestone adds streaming repeated-sample
ergonomics matching `WeightedChoice.iter*`, dynamic weighted-tree iterators, and
Rust `sample_iter` style workflows.

## Local Rust Reference

Audited local Rust evidence:

- cached local `rand_distr 0.6.0` exposes `weighted::WeightedAliasIndex` as a
  static alias-table weighted-index sampler;
- Rust users commonly repeat distribution samples through `sample_iter` style
  workflows;
- Alea reusable `WeightedChoice` and dynamic weighted trees already expose
  `iter` / direct-source iterator helpers.

This milestone adds iterator ergonomics to the lower-level static alias-table
sampler without changing canonical `sample`, `fill`, or owned-batch behavior.

## Alea API Added

`src/distributions.zig` now exposes:

- `AliasTable.iter`;
- `AliasTable.iterFrom`;
- `AliasTable.iterU32`;
- `AliasTable.iterU32From`;
- `AliasTable.U32IndexIterator`.

`iter` / `iterFrom` reuse `Rng.SampleIterator` and produce repeated `usize`
indexes. `iterU32` / `iterU32From` produce compact `u32` indexes and include a
caller-owned `fill` method. The iterators preserve the canonical sample/fill
stream shape and deterministic `constantIndex` no-consume behavior.

Focused tests verify:

- `iterFrom` matches repeated `sampleFrom` under identical seeds;
- iterator `fill` matches canonical `fillFrom` under identical seeds;
- `iterU32From` matches canonical `fillU32CheckedFrom` under identical seeds;
- facade and direct-source iterator paths preserve stream shape;
- single-positive alias-table iterators fill deterministic indexes without
  consuming the random stream.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `alias u32 iterator fill`.
- `tools/examplecheck.zig` verifies that example token.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe static alias-table index iterators.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "alias table iterators"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked static weighted-sampler streaming ergonomics
gap only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
