# S4-M187 Exact-Size Iterator Size Hints

Result: passed.

Purpose: add exact lower/upper `sizeHint()` diagnostics to Alea's bounded index
and sampled iterators. This mirrors Rust `Iterator::size_hint` discoverability
for local `rand` exact-size iterators while preserving the existing Zig-native
`remaining()` and `len()` helpers.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/index.rs` implements `size_hint()` for
  `IndexVecIter` and `IndexVecIntoIter`, returning the backing iterator's exact
  lower and upper bounds, and both types implement `ExactSizeIterator`.
- `/home/passchaos/Work/rand/src/seq/slice.rs` implements `size_hint()` for
  `IndexedSamples` as `(self.indices.len(), Some(self.indices.len()))` and
  implements `ExactSizeIterator::len`.

Alea does not copy Rust trait mechanics. It exposes an explicit `seq.SizeHint`
struct and direct `sizeHint()` methods on iterator types whose remaining length
is exact.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.SizeHint`;
- `IndexVec.Iterator.sizeHint`;
- `IndexVec.IntoIterator.sizeHint`;
- mapped `IndexVec` iterator `sizeHint()` methods for values, const pointers,
  and mutable pointers;
- `SampledValueIterator.sizeHint`;
- `SampledPtrIterator.sizeHint`;
- `SampledMutPtrIterator.sizeHint`.

Semantics:

- returns `.lower == remaining()`;
- returns `.upper == remaining()` for these exact-size iterators;
- decreases after each `next()` or `fill()` operation;
- reaches `0..0` after exhaustion;
- does not change ownership or allocator cleanup requirements.

Focused tests verify size hints for borrowed and consuming index iteration,
mapped value/pointer/mutable-pointer iterators, and sampled
value/const-pointer/mutable-pointer iterators before/after `next()` or `fill()`.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `sizeHint=0..0` diagnostics for
  consuming `IndexVec` iteration and sampled value-iterator fill output.
- `docs/api-reference.md` lists the new `SizeHint` and `sizeHint` public
  symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe exact-size iterator size hints.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M188.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "index vec"`
- `zig test src/root.zig --test-filter "sampleItemsIter"`
- `zig test src/root.zig --test-filter "samplePtrsIter"`
- `zig test src/root.zig --test-filter "sampleMutPtrsIter"`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked exact-size iterator diagnostics gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
