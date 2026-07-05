# S4-M181 Sampled Pointer Iterators

Result: passed.

Purpose: add owned no-replacement sampled pointer iterators, matching local Rust
`IndexedSamples` / `SliceChooseIter` workflows. Rust `slice.sample(...)` owns an
`IndexVecIntoIter` and yields references into the source slice. Alea already had
allocation-returning and caller-owned pointer samples; this milestone adds the
iterator form.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/slice.rs` defines `IndexedSamples`;
- `IndexedSamples` stores a slice reference plus an `IndexVecIntoIter`;
- it yields `&T` and reports exact remaining length.

Alea keeps allocator ownership explicit: `SampledPtrIterator` owns a sampled
`IndexVec.IntoIterator` and must be deinitialized.

## Alea API Added

`src/seq.zig` now exposes:

- `SampledPtrIterator(T)`;
- `SampledPtrIterator.next`;
- `SampledPtrIterator.remaining`;
- `SampledPtrIterator.deinit`;
- `seq.samplePtrsIter`;
- `seq.samplePtrsIterFrom`;
- `seq.samplePtrsIterChecked`;
- `seq.samplePtrsIterCheckedFrom`.

Semantics:

- samples distinct indexes without replacement using existing `IndexVec` logic;
- streams `*const T` references into the source slice;
- tracks exact remaining count;
- optional-style forms clamp `amount` to `items.len`, matching existing
  `samplePtrs` / `chooseMultiplePtrs` allocation-returning behavior;
- checked forms reject `amount > items.len` without consuming randomness;
- allocation failure is reported and leaves randomness unconsumed where
  allocation fails before drawing.

Focused tests verify pointer identity, no repeated indexes, exact remaining
counts, empty no-consume behavior, facade/direct stream-shape parity,
checked invalid no-consume behavior, and allocation failure handling.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints a `samplePtrsIter` row.
- `tools/examplecheck.zig` verifies that example source token.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe owned sampled pointer iterators.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "samplePtrsIter"`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked sampled pointer iterator ergonomics gap only.
It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
