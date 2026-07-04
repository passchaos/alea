# S4-M124 Slice Sample Aliases

Result: passed.

Purpose: make Alea's no-replacement slice item and pointer subset sampling
discoverable under terminology matching local Rust `IndexedRandom::sample`.
Alea already had `chooseMultiple*` helpers; this milestone adds explicit
`sampleItems*`, `samplePtrs*`, and `sampleMutPtrs*` aliases instead of copying
Rust trait shapes.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs`:

- `IndexedRandom::sample(rng, amount)` returns an iterator over distinct slice
  elements;
- examples show both collection into an owned vector and filling an existing
  buffer;
- `sample_array` remains the fixed-size array form, already covered by Alea's
  `chooseArray*` and `sampleArray*` APIs.

## Alea API Added

`src/seq.zig` now exposes allocation-returning aliases:

- `seq.sampleItems`, `seq.sampleItemsFrom`, `seq.sampleItemsChecked`,
  `seq.sampleItemsCheckedFrom`;
- `seq.samplePtrs`, `seq.samplePtrsFrom`, `seq.samplePtrsChecked`,
  `seq.samplePtrsCheckedFrom`;
- `seq.sampleMutPtrs`, `seq.sampleMutPtrsFrom`, `seq.sampleMutPtrsChecked`,
  `seq.sampleMutPtrsCheckedFrom`.

It also exposes caller-owned buffer aliases:

- `seq.sampleItemsInto`, `seq.sampleItemsIntoFrom`,
  `seq.sampleItemsIntoChecked`, `seq.sampleItemsIntoCheckedFrom`;
- `seq.samplePtrsInto`, `seq.samplePtrsIntoFrom`,
  `seq.samplePtrsIntoChecked`, `seq.samplePtrsIntoCheckedFrom`;
- `seq.sampleMutPtrsInto`, `seq.sampleMutPtrsIntoFrom`,
  `seq.sampleMutPtrsIntoChecked`, `seq.sampleMutPtrsIntoCheckedFrom`.

These forward to the existing no-replacement `chooseMultiple*` item/const-pointer
and mutable-pointer workflows. Focused tests verify facade/direct stream parity,
checked invalid-count no-consume behavior, scratch-length errors, and zero-count
no-consume behavior through the underlying implementations.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `sampleItemsFrom` and
  `sampleItemsIntoFrom`.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the slice sample aliases.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "slice sampleItems"`
- `zig build test`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked API discoverability gap only. It does not
resolve S4-M11's exact/default-compatible dense SIMD normal/exponential blocker,
does not add a new architecture/runtime runner, and is not whole-goal completion
evidence.
