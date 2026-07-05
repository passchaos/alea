# S4-M182 Sampled Value Iterators

Result: passed.

Purpose: add owned no-replacement sampled value iterators, complementing S4-M181
sampled pointer iterators. Local Rust `IndexedSamples` yields references and is
commonly collected with `.cloned()` for owned values; Alea now exposes a direct
value stream using the same sampled index ownership model.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/slice.rs` defines `IndexedSamples`, storing
  a slice reference plus an `IndexVecIntoIter`;
- examples collect references into owned values via `.cloned().collect()`;
- exact remaining length is available through the underlying iterator.

Alea keeps allocator ownership explicit: `SampledValueIterator` owns a sampled
`IndexVec.IntoIterator`, streams copied values, and must be deinitialized.

## Alea API Added

`src/seq.zig` now exposes:

- `SampledValueIterator(T)`;
- `SampledValueIterator.next`;
- `SampledValueIterator.remaining`;
- `SampledValueIterator.deinit`;
- `seq.sampleItemsIter`;
- `seq.sampleItemsIterFrom`;
- `seq.sampleItemsIterChecked`;
- `seq.sampleItemsIterCheckedFrom`.

Semantics:

- samples distinct indexes without replacement using existing `IndexVec` logic;
- streams copied `T` values from the source slice;
- tracks exact remaining count;
- optional-style forms clamp `amount` to `items.len`, matching existing
  `sampleItems` / `chooseMultiple` allocation-returning behavior;
- checked forms reject `amount > items.len` without consuming randomness;
- allocation failure is reported and leaves randomness unconsumed where
  allocation fails before drawing.

Focused tests verify no repeated values, exact remaining counts, empty
no-consume behavior, facade/direct stream-shape parity, checked invalid
no-consume behavior, and allocation failure handling.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints a `sampleItemsIter` row.
- `tools/examplecheck.zig` verifies that example source token.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe owned sampled value iterators.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "sampleItemsIter"`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked sampled value iterator ergonomics gap only.
It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
