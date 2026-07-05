# S4-M188 IndexVec Iterator Fill Helpers

Result: passed.

Purpose: add caller-buffer `fill()` helpers to bounded `IndexVec` index and
mapped item iterators. Local Rust `rand` exposes `IndexVecIter`,
`IndexVecIntoIter`, and `IndexedSamples` as exact-size iterators that can be
collected or zipped into caller buffers. Alea now gives the bounded IndexVec
iterator family a direct Zig-native caller-buffer fill path, matching the
sampled iterator fill helpers added earlier.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/index.rs` implements `Iterator` plus
  exact-size `size_hint` / `ExactSizeIterator` behavior for `IndexVecIter` and
  `IndexVecIntoIter`.
- `/home/passchaos/Work/rand/src/seq/slice.rs` implements iterator behavior for
  `IndexedSamples`, including exact size hints; Rust callers can use iterator
  adapters such as `collect` or `zip(buf.iter_mut())` to move remaining items
  into caller-owned storage.

Alea keeps explicit methods instead of Rust trait adapters. The new methods
make the caller-buffer path discoverable on the exact-size IndexVec iterators
without changing existing `next`, `remaining`, `len`, or `sizeHint` behavior.

## Alea API Added

`src/seq.zig` now exposes:

- `IndexVec.Iterator.fill`;
- `IndexVec.IntoIterator.fill`;
- `IndexVec.ValueIterator.fill`;
- `IndexVec.PtrIterator.fill`;
- `IndexVec.MutPtrIterator.fill`.

Semantics:

- fills up to `min(dest.len, remaining())`;
- returns the number of slots filled;
- advances the iterator by the filled count;
- updates exact `remaining()`, `len()`, and `sizeHint()` diagnostics;
- preserves consuming-iterator allocator ownership and cleanup requirements;
- works for copied values, const pointers, and distinct mutable pointers when
  the iterator was produced through the existing checked mutable-pointer path.

Focused tests verify partial fills, tail fills, exact remaining-count updates,
exact size hints, consuming owned-index fills, mapped value fills, const-pointer
fills, and mutable updates through filled mutable pointers.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `IndexVec.iter.fill` and
  `IndexVec.values.fill` rows with exact remaining/sizeHint diagnostics.
- `tools/examplecheck.zig` now checks those example source tokens.
- `docs/api-reference.md` lists the new public `fill` symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the IndexVec iterator fill helpers.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M189.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "index vec"`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked IndexVec iterator caller-buffer ergonomics
gap only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
