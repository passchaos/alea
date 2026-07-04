# S4-M133 Seq Owned Repeated Choice Batches

Result: passed.

Purpose: make allocation-returning repeated with-replacement slice choices
discoverable in the `seq` namespace. Alea already had `Rng.choose*Batch` and
reusable `Choice.values` / `Choice.ptrs`; this milestone adds `seq.choose*Batch`
aliases for users coming from local Rust `IndexedRandom::choose_iter(...).take(n)
.collect()` workflows.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs`:

- `IndexedRandom::choose_iter(rng)` returns an iterator that samples from a
  slice with replacement;
- examples use `.take(n)` for repeated choices and callers may collect those
  repeated choices into owned storage.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.chooseBatch`;
- `seq.chooseBatchFrom`;
- `seq.chooseBatchChecked`;
- `seq.chooseBatchCheckedFrom`;
- `seq.chooseConstPtrBatch`;
- `seq.chooseConstPtrBatchFrom`;
- `seq.chooseConstPtrBatchChecked`;
- `seq.chooseConstPtrBatchCheckedFrom`;
- `seq.choosePtrBatch`;
- `seq.choosePtrBatchFrom`;
- `seq.choosePtrBatchChecked`;
- `seq.choosePtrBatchCheckedFrom`.

These forward to existing `Rng.choose*Batch` helpers while using `seq`-style
`error.EmptyInput` in checked empty-input paths. Zero-count checked batches
allocate empty outputs before validating item slices, and single-item slices
fill deterministically without consuming randomness after allocation.

Focused tests verify:

- facade/direct stream-shape parity against the existing `Rng` helpers;
- value, const-pointer, and mutable-pointer allocation-returning outputs;
- zero-count checked no-consume behavior;
- checked empty-input no-consume behavior;
- singleton no-consume behavior;
- allocation-failure no-consume behavior.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `seq.chooseBatchFrom` and
  `seq.chooseConstPtrBatchFrom` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the `seq.chooseBatch` aliases.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "seq choice batch"`
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
