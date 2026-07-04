# S4-M136 Accessor-Weighted Choice Batches

Result: passed.

Purpose: make allocation-returning repeated with-replacement weighted choices
from item-derived weights available without first constructing a reusable
`WeightedChoice` table. S4-M135 added caller-owned fills; this milestone adds
owned batches for value, const-pointer, and mutable-pointer outputs.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs`:

- `IndexedRandom::choose_weighted(rng, |item| ...)` builds a weighted-index
  distribution over item-derived weights and returns a selected reference;
- `IndexedMutRandom::choose_weighted_mut(rng, |item| ...)` provides the mutable
  reference variant;
- `IndexedRandom::choose_weighted_iter(rng, |item| ...)` returns an iterator for
  repeated with-replacement weighted choices.

Rust callers can collect `choose_weighted_iter(...).take(n)` into owned storage.
Alea now provides direct Zig allocation-returning helpers for that workflow,
while preserving the reusable `WeightedChoice.initBy` path for workloads that
want to reuse an alias table across many repeated choices.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.chooseWeightedBatchBy`;
- `seq.chooseWeightedBatchByFrom`;
- `seq.chooseWeightedBatchByChecked`;
- `seq.chooseWeightedBatchByCheckedFrom`;
- `seq.chooseWeightedConstPtrBatchBy`;
- `seq.chooseWeightedConstPtrBatchByFrom`;
- `seq.chooseWeightedConstPtrBatchByChecked`;
- `seq.chooseWeightedConstPtrBatchByCheckedFrom`;
- `seq.chooseWeightedPtrBatchBy`;
- `seq.chooseWeightedPtrBatchByFrom`;
- `seq.chooseWeightedPtrBatchByChecked`;
- `seq.chooseWeightedPtrBatchByCheckedFrom`.

Optional output batches (`[]?T`, `[]?*const T`, `[]?*T`) represent all-zero or
empty weight input with `null` entries. Checked batches reject those paths with
`error.EmptyInput`. Zero-count batches allocate empty outputs before validating
weights or drawing. Non-zero batches validate item-derived weights before
allocation and drawing; negative, non-finite, or overflowing totals return
`error.InvalidWeight`.

Focused tests verify:

- value, const-pointer, and mutable-pointer owned batches;
- facade/direct stream-shape parity for `ScalarPrng` and `DefaultPrng`;
- zero-count no-consume behavior before validating weights;
- empty/all-zero optional no-consume behavior;
- checked empty/all-zero no-consume behavior;
- single-positive no-consume behavior after allocation;
- invalid-weight no-consume behavior;
- allocation-failure no-consume behavior.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `weighted by value batch`,
  `weighted by const ptr batch`, and `weighted by mut ptr batch` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the accessor-weighted batch helpers.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "chooseWeightedBatchBy"`
- `zig build test`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked weighted sequence ergonomics gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
