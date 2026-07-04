# S4-M128 Fixed-Size Slice Sample Aliases

Result: passed.

Purpose: make Alea's fixed-size no-replacement slice value and pointer arrays
discoverable under terminology matching local Rust `IndexedRandom::sample_array`.
Alea already had `chooseArray*` helpers; this milestone adds explicit
`sampleItemsArray*`, `samplePtrArray*`, and `sampleMutPtrArray*` aliases instead
of copying Rust trait shapes.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs`:

- `IndexedRandom::sample_array(rng)` returns a fixed-size array of distinct
  slice elements;
- `sample_array` is distinct from the allocation-returning `sample` API;
- mutable slice choice remains a separate Rust trait path.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.sampleItemsArray`;
- `seq.sampleItemsArrayFrom`;
- `seq.sampleItemsArrayChecked`;
- `seq.sampleItemsArrayCheckedFrom`;
- `seq.samplePtrArray`;
- `seq.samplePtrArrayFrom`;
- `seq.samplePtrArrayChecked`;
- `seq.samplePtrArrayCheckedFrom`;
- `seq.sampleMutPtrArray`;
- `seq.sampleMutPtrArrayFrom`;
- `seq.sampleMutPtrArrayChecked`;
- `seq.sampleMutPtrArrayCheckedFrom`.

These forward to existing fixed-size `chooseArray*`, `choosePtrArray*`, and
`chooseMutPtrArray*` workflows. Focused tests verify facade/direct stream parity,
checked invalid-count no-consume behavior, optional null behavior, and zero-count
no-consume behavior through the underlying implementation.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `sampleItemsArrayFrom`,
  `samplePtrArrayFrom`, and `sampleMutPtrArrayFrom`.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the fixed-size sample-array aliases.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "fixed-size slice sample aliases"`
- `zig build test`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked sequence API discoverability gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
