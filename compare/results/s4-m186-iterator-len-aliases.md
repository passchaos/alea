# S4-M186 Exact-Size Iterator Length Aliases

Result: passed.

Purpose: add `len()` aliases to Alea's bounded index and sampled iterators so
their exact remaining length is as discoverable as Rust `ExactSizeIterator::len`,
while preserving the existing Zig-native `remaining()` names.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/index.rs` implements
  `ExactSizeIterator` for `IndexVecIter` and `IndexVecIntoIter`; the exact
  length is surfaced by the standard `len()` method.
- `/home/passchaos/Work/rand/src/seq/slice.rs` implements
  `ExactSizeIterator::len` for `IndexedSamples`, returning the exact remaining
  sampled index count through the owned `IndexVecIntoIter`.

Alea keeps explicit methods instead of copying Rust trait machinery. The new
`len()` methods are aliases for `remaining()` so existing users keep the
Zig-native spelling and Rust-comparison users can find the familiar exact-size
name.

## Alea API Added

`src/seq.zig` now exposes:

- `IndexVec.Iterator.len`;
- `IndexVec.IntoIterator.len`;
- mapped `IndexVec` iterator `len()` methods for values, const pointers, and
  mutable pointers;
- `SampledValueIterator.len`;
- `SampledPtrIterator.len`;
- `SampledMutPtrIterator.len`.

Semantics:

- returns the same value as `remaining()`;
- decreases after each `next()` or `fill()` operation;
- reaches zero after the iterator is exhausted;
- does not change ownership or allocator cleanup requirements.

Focused tests verify index-vector iteration, consuming index iteration, mapped
value/pointer/mutable-pointer iterators, and sampled value/const-pointer/
mutable-pointer iterators.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints a `sampleItemsIter.fill` row with
  both `remaining` and `len` diagnostics.
- `docs/api-reference.md` lists the new public `len` symbols.
- `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe exact-size iterator length aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M187.

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

This milestone closes an unblocked exact-size iterator discoverability gap only.
It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
