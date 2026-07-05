# S4-M287 Sequence Index Namespace Audit

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout exposes low-level index sampling through
`rand::seq::index`:

- `~/Work/rand/src/seq/mod.rs` declares `pub mod index`.
- That module re-exports `super::index_::*` when allocation is enabled.
- It also defines `index::sample_array(rng, len)` for fixed-size no-replacement
  index arrays.
- `~/Work/rand/src/seq/index.rs` defines `IndexVec`, `IndexVecIter`,
  `IndexVecIntoIter`, `sample(rng, length, amount)`, and
  `sample_weighted(rng, length, weight, amount)`.

## Alea Position

Alea already covers the concrete `rand::seq::index` workflows through top-level
Zig-native `seq` APIs:

- `seq.IndexVec` provides compact owned index storage with `len`, `isEmpty`,
  `index`, `at`, `get`, `iter`, `intoIter`, `intoVec`, owned-slice conversions,
  `u32` export, value/pointer/mutable-pointer mapping, clone, and
  representation-independent equality.
- `seq.sampleIndexVec`, `sampleIndices`, `sampleIndicesU32`,
  `sampleIndicesInto`, `sampleIndicesU32Into`, `sampleArray`, and
  `sampleArrayU32` cover allocation-returning, caller-owned, compact `u32`, and
  fixed-size no-replacement index sampling.
- `seq.sampleWeightedIndexVec`, `sampleWeightedIndices`,
  `sampleWeightedIndicesU32`, caller-owned weighted-index buffers,
  `sampleWeightedIndexArray`, `sampleWeightedIndexArrayU32`, and the item- and
  index-accessor variants cover Rust `sample_weighted` and fixed-size weighted
  index workflows.
- Slice/value/pointer wrappers (`sampleItems*`, `samplePtrs*`,
  `sampleMutPtrs*`, `IndexedSamples`, and `SliceChooseIter`) expose the higher
  item-level workflows built from these index samples.

Alea intentionally does not add a public `seq.index` namespace today:

- `seq.index` would be a Rust path-layout copy, not a new workflow. The current
  top-level `seq.*` names are shorter, Zig-native, and already documented.
- A direct top-level declaration named `index` in `src/seq.zig` is not a
  harmless alias: the file has many local variables and captures named `index`,
  and Zig rejects local names that shadow top-level declarations. Adding the
  namespace would therefore require a broad non-product renaming pass to
  preserve an otherwise redundant Rust module path.
- A differently named namespace such as `indices` would not close the exact
  Rust `rand::seq::index` discovery path and would add duplicate surface area.

## Result

No new unblocked implementation gap is identified for local Rust
`rand::seq::index`. Alea's top-level `seq` APIs cover the concrete sampling,
owned-index, fixed-size-array, compact-index, weighted-index, and item-mapping
workflows. The exact intermediate Rust module path is intentionally not copied
unless a future concrete Zig-native workflow justifies the additional surface
and associated rename cost.

## Validation

This is documentation/evidence only. Relevant validation:

```sh
zig fmt tools/roadmapcheck.zig
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```

## Non-Completion Note

This audit does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
