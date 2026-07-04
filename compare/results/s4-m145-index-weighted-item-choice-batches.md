# S4-M145 Index-Weighted Item Choice Batches

Result: passed.

Purpose: allocate repeated weighted value, const-pointer, and mutable-pointer
choice batches from an item slice plus a comptime index-weight function. S4-M144
added the caller-owned repeated fill form; this milestone adds owned batches
while keeping weights derived from positions instead of item fields or a
parallel weight slice.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs` and
`/home/passchaos/Work/rand/src/seq/index.rs`:

- `IndexedRandom::choose_weighted_iter(rng, |item| ...)` repeats weighted
  reference selection with replacement and can be collected into owned storage;
- `IndexedRandom::choose_weighted(rng, |item| ...)` and
  `IndexedMutRandom::choose_weighted_mut(rng, |item| ...)` map weighted indexes
  back to immutable or mutable references;
- `index::sample_weighted(rng, length, |index| ..., amount)` demonstrates the
  local Rust length/index-weight accessor shape.

Alea already supports item-accessor weighted batches and index-weighted
caller-owned fills. This milestone combines those ergonomics: callers can
allocate repeated value/pointer batches using an index-derived weight function
without constructing a parallel weight slice or manually mapping indexes.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.chooseWeightedBatchByIndex`;
- `seq.chooseWeightedBatchByIndexFrom`;
- `seq.chooseWeightedBatchByIndexChecked`;
- `seq.chooseWeightedBatchByIndexCheckedFrom`;
- `seq.chooseWeightedConstPtrBatchByIndex`;
- `seq.chooseWeightedConstPtrBatchByIndexFrom`;
- `seq.chooseWeightedConstPtrBatchByIndexChecked`;
- `seq.chooseWeightedConstPtrBatchByIndexCheckedFrom`;
- `seq.chooseWeightedPtrBatchByIndex`;
- `seq.chooseWeightedPtrBatchByIndexFrom`;
- `seq.chooseWeightedPtrBatchByIndexChecked`;
- `seq.chooseWeightedPtrBatchByIndexCheckedFrom`.

Optional batch helpers return `null` entries for empty slices or all-zero
index-derived weights. Checked helpers reject those paths with
`error.EmptyInput`. Invalid negative, NaN, infinite, or overflowing weights
return `error.InvalidWeight`. Single-positive weights fill deterministically
after allocation without consuming randomness. Zero-count batches allocate empty
outputs before validating weights or drawing.

Focused tests verify:

- value, const-pointer, and mutable-pointer allocation-returning outputs;
- checked and optional forms;
- facade/direct stream-shape parity for `ScalarPrng` and `DefaultPrng`;
- zero-count no-consume behavior before validating weights;
- empty/all-zero optional no-consume behavior;
- checked empty/all-zero no-consume behavior;
- single-positive no-consume behavior after allocation;
- invalid-weight no-consume behavior;
- allocation-failure no-consume behavior.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `weighted index-weight value batch`,
  `weighted index-weight const ptr batch`, and
  `weighted index-weight mut ptr batch items` rows.
- `tools/examplecheck.zig` verifies those example tokens and the summary token.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the index-weighted item choice batch helpers.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "chooseWeightedBatchByIndex"`
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
