# S4-M299 WeightedTree `is_valid` Manifest Mapping

Date: 2026-07-06

## Purpose

The cached local `rand_distr 0.6.0` dynamic weighted tree exposes
`WeightedTreeIndex::is_valid()`, which returns whether the tree can be sampled
(total weight greater than zero). Alea already exposes equivalent readiness
diagnostics as `WeightedTree.isValid()` and `WeightedIntTree.isValid()`, but the
S4-M294 manifest and parity matrix did not explicitly name the local Rust
`is_valid` surface.

## Change

S4-M299 makes this mapping explicit:

- `compare/results/s4-m294-rand-distr-public-surface-manifest.md` now maps
  `WeightedTreeIndex` and `is_valid` to Alea dynamic-tree APIs;
- `compare/results/distribution-parity-matrix.md` now lists `isValid` among the
  weighted-tree parity diagnostics;
- `docs/core-guide.md` mentions `isValid` as the local
  `rand_distr::WeightedTreeIndex::is_valid`-style sampling readiness diagnostic;
- `tools/surfacecheck.zig` now requires the `is_valid` token in the local
  `rand_distr` manifest expected-token set.

No new code API was needed: the relevant Alea APIs already existed.

## Validation

Relevant validation:

```sh
zig fmt tools/surfacecheck.zig tools/roadmapcheck.zig
zig build surfacecheck
zig build roadmapcheck
zig build doccheck
zig build test
git diff --check
```

## Non-Completion Note

This milestone closes an evidence/manifest mapping gap for an already-existing
Alea readiness diagnostic. It does not resolve S4-M11's exact/default-compatible
dense SIMD normal/exponential blocker, does not add an additional
architecture/runtime runner, and is not whole-goal completion evidence.
