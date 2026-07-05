# S4-M183 Sampled Mutable-Pointer Iterators

Result: passed.

Purpose: add owned no-replacement sampled mutable-pointer iterators. Rust
`IndexedSamples` yields immutable references; Alea already supports mutable
pointer no-replacement samples through allocation-returning and caller-owned
APIs. This milestone extends the S4-M181/S4-M182 iterator pattern to mutable
pointers while preserving distinct sampled indexes.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/slice.rs` defines `IndexedSamples`, storing
  a slice reference plus an `IndexVecIntoIter`;
- local Rust mutable single choice is available through `choose_weighted_mut` /
  `choose_mut`, while sampled iterator references are immutable;
- Alea can exceed that surface with Zig-native mutable-pointer iterators because
  sampled indexes are distinct.

## Alea API Added

`src/seq.zig` now exposes:

- `SampledMutPtrIterator(T)`;
- `SampledMutPtrIterator.next`;
- `SampledMutPtrIterator.remaining`;
- `SampledMutPtrIterator.deinit`;
- `seq.sampleMutPtrsIter`;
- `seq.sampleMutPtrsIterFrom`;
- `seq.sampleMutPtrsIterChecked`;
- `seq.sampleMutPtrsIterCheckedFrom`.

Semantics:

- samples distinct indexes without replacement using existing `IndexVec` logic;
- streams distinct `*T` references into the mutable source slice;
- tracks exact remaining count;
- optional-style forms clamp `amount` to `items.len`, matching existing
  `sampleMutPtrs` / `chooseMultipleMutPtrs` allocation-returning behavior;
- checked forms reject `amount > items.len` without consuming randomness;
- allocation failure is reported and leaves randomness unconsumed where
  allocation fails before drawing.

Focused tests verify mutable updates through streamed pointers, distinct sampled
indexes, exact remaining counts, empty no-consume behavior, facade/direct
stream-shape parity, checked invalid no-consume behavior, and allocation failure
handling.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints a `sampleMutPtrsIter` row.
- `tools/examplecheck.zig` verifies that example source token.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe owned sampled mutable-pointer iterators.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "sampleMutPtrsIter"`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked sampled mutable-pointer iterator ergonomics
gap only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
