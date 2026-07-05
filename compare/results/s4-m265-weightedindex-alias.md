# S4-M265 WeightedIndex Alias

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout exposes reusable weighted-index sampling through
the distribution weighted namespace:

- `~/Work/rand/src/distr/weighted/mod.rs` contains
  `pub use weighted_index::WeightedIndex;`.
- `~/Work/rand/src/distr/weighted/weighted_index.rs` defines
  `pub struct WeightedIndex<X: SampleUniform + PartialOrd>`.
- The Rust type exposes `new`, `update_weights`, `weight`, `weights`,
  `total_weight`, and `Distribution<usize>` sampling.

Alea already had a richer static weighted sampler under
`distributions.AliasTable(Weight)`, including `new`, `updateWeights`,
`updateMany`, `updateAt`, optional `weight` / `probability`, `weightIter`,
`totalWeight`, compact `u32` output, fixed index arrays, owned batches, and
iterator workflows. The Rust-discoverable `WeightedIndex` reusable-sampler name
was missing.

## Alea Change

Alea now provides:

```zig
pub fn WeightedIndex(comptime Weight: type) type {
    return AliasTable(Weight);
}
```

This is a name alias over the existing O(1) alias-table sampler, not a new
Fenwick/tree implementation. It preserves Alea's existing `AliasTable`
behavior and diagnostics while making ported local Rust weighted-distribution
examples easier to discover.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `WeightedIndex alias mirrors AliasTable` verifies that
  `WeightedIndex(Weight)` is the same type as `AliasTable(Weight)`, that
  construction and diagnostics match, that sampling preserves stream shape
  against `AliasTable`, and that `updateWeights` preserves updated totals and
  probabilities.

Documentation/example updates:

- `examples/weighted_sampling.zig` prints `WeightedIndex alias numChoices`.
- `tools/examplecheck.zig` guards that token.
- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`,
  `docs/examples.md`, and `compare/results/distribution-parity-matrix.md`
  document the alias.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M266.

Validation commands for this milestone:

```sh
zig test src/distributions.zig --test-filter "WeightedIndex alias"
zig build run-weighted-sampling
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```
