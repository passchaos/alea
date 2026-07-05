# S4-M185 Sampled Iterator Fill Helpers

Result: passed.

Purpose: add caller-buffer fill helpers to owned sampled value/const-pointer/
mutable-pointer iterators. Local Rust `IndexedSamples` documentation shows
filling an existing buffer by zipping sampled references into `iter_mut()`.
Alea now exposes direct Zig-native `fill` helpers on the sampled iterators.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/slice.rs` documents using
  `sample(...).zip(buf.iter_mut())` to fill an existing buffer;
- `IndexedSamples` reports exact remaining length through its iterator.

Alea uses explicit methods on the owned sampled iterators, avoiding users having
to hand-write the loop.

## Alea API Added

`src/seq.zig` now exposes:

- `SampledValueIterator.fill`;
- `SampledPtrIterator.fill`;
- `SampledMutPtrIterator.fill`.

Semantics:

- fills up to `min(dest.len, remaining())` values/pointers;
- returns the number of slots filled;
- advances the iterator and updates exact remaining count;
- works for copied values, const pointers, and mutable pointers.

Focused tests verify partial fills, tail fills, exact remaining-count updates,
and mutable updates through filled mutable pointers.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints a `sampleItemsIter.fill` row.
- `tools/examplecheck.zig` verifies that example source token.
- `docs/api-reference.md` lists the new public symbols.
- `README.md`, `docs/examples.md`, `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe sampled iterator fill helpers.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "sampleItemsIter"`
- `zig test src/root.zig --test-filter "samplePtrsIter"`
- `zig test src/root.zig --test-filter "sampleMutPtrsIter"`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked sampled iterator fill ergonomics gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
