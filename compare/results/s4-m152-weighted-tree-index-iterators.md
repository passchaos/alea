# S4-M152 Weighted Tree Index Iterators

Result: passed.

Purpose: add repeated with-replacement index iterators to dynamic weighted
trees. `WeightedChoice` already exposes iterator workflows for repeated
sampling, and Rust users commonly reach repeated draws through `sample_iter`
style APIs. Dynamic `WeightedTree` / `WeightedIntTree` now provide the same
streaming ergonomics without requiring caller-owned buffers or an owned batch.

## Local Rust Reference

Audited local Rust evidence:

- cached local `rand_distr 0.6.0` exposes `weighted::WeightedTreeIndex` as a
  dynamic weighted-index sampler;
- `/home/passchaos/Work/rand/src/seq/slice.rs` exposes repeated weighted draws
  through iterator forms such as `choose_weighted_iter`;
- Alea reusable `WeightedChoice` already has `iter` / `iterFrom` for repeated
  weighted item sampling.

This milestone brings repeated iterator ergonomics to dynamic weighted-index
trees while keeping `sample`, caller-owned `fill`, and owned `indices` APIs
unchanged.

## Alea API Added

`src/distributions.zig` now exposes for both `WeightedTree(Weight)` and
`WeightedIntTree(Weight)`:

- `iter`;
- `iterFrom`;
- `iterU32`;
- `iterU32From`;
- `U32IndexIterator`.

`iter` / `iterFrom` reuse `Rng.SampleIterator` and produce repeated `usize`
indexes. `iterU32` / `iterU32From` produce compact `u32` indexes for
populations that fit `u32`, with a `fill` method for caller-owned compact
buffers. The iterators preserve the canonical sample/fill stream shape and the
single-positive no-consume behavior of the underlying tree.

Focused tests verify:

- generic `WeightedTree(f64)` iterators match canonical `sampleFrom` and
  `fillFrom` outputs under identical seeds;
- generic `WeightedTree(f64)` `iterU32From` matches canonical `fillU32From`
  output under identical seeds;
- facade and direct-source iterator paths preserve stream shape;
- unsigned `WeightedIntTree(u32)` iterators match canonical `fillFrom` and
  `fillU32From` outputs under identical seeds;
- single-positive integer-tree iterators fill deterministic indexes without
  consuming the random stream.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `dynamic tree iterator next` and
  `integer tree u32 iterator fill`.
- `tools/examplecheck.zig` verifies those tokens and the `iter/iterU32` summary
  token.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe dynamic-tree index iterators.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "weighted tree iterators"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked weighted dynamic-tree streaming ergonomics
gap only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
