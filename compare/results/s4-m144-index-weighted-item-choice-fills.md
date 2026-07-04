# S4-M144 Index-Weighted Item Choice Fills

Result: passed.

Purpose: fill caller-owned repeated weighted value, const-pointer, and
mutable-pointer choices from an item slice plus a comptime index-weight function.
S4-M143 added the one-shot choice form; this milestone adds the caller-owned
repeated fill form while keeping weights derived from positions instead of item
fields or a parallel weight slice.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs` and
`/home/passchaos/Work/rand/src/seq/index.rs`:

- `IndexedRandom::choose_weighted_iter(rng, |item| ...)` repeats weighted
  reference selection with replacement;
- `IndexedRandom::choose_weighted(rng, |item| ...)` and
  `IndexedMutRandom::choose_weighted_mut(rng, |item| ...)` map weighted indexes
  back to immutable or mutable references;
- `index::sample_weighted(rng, length, |index| ..., amount)` demonstrates the
  local Rust length/index-weight accessor shape.

Alea already supports item-accessor weighted caller-owned fills and
index-weighted one-shot item choices. This milestone combines those ergonomics:
callers can fill value/pointer buffers using an index-derived weight function
without constructing a parallel weight slice or manually mapping indexes.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.fillChooseWeightedByIndex`;
- `seq.fillChooseWeightedByIndexFrom`;
- `seq.fillChooseWeightedByIndexChecked`;
- `seq.fillChooseWeightedByIndexCheckedFrom`;
- `seq.fillChooseWeightedConstPtrByIndex`;
- `seq.fillChooseWeightedConstPtrByIndexFrom`;
- `seq.fillChooseWeightedConstPtrByIndexChecked`;
- `seq.fillChooseWeightedConstPtrByIndexCheckedFrom`;
- `seq.fillChooseWeightedPtrByIndex`;
- `seq.fillChooseWeightedPtrByIndexFrom`;
- `seq.fillChooseWeightedPtrByIndexChecked`;
- `seq.fillChooseWeightedPtrByIndexCheckedFrom`.

Optional fill helpers write `null` for empty slices or all-zero index-derived
weights. Checked helpers reject those paths with `error.EmptyInput`. Invalid
negative, NaN, infinite, or overflowing weights return `error.InvalidWeight`.
Single-positive weights fill deterministically without consuming randomness.
Zero-length destination buffers return before validating weights or drawing.

Focused tests verify:

- value, const-pointer, and mutable-pointer caller-owned outputs;
- checked and optional forms;
- facade/direct stream-shape parity for `ScalarPrng` and `DefaultPrng`;
- zero-length destination no-consume behavior;
- empty/all-zero optional no-consume behavior;
- checked empty/all-zero no-consume behavior;
- single-positive no-consume behavior;
- invalid-weight no-consume behavior.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `weighted index-weight value fill`,
  `weighted index-weight const ptr fill`, and
  `weighted index-weight mut ptr fill items` rows.
- `tools/examplecheck.zig` verifies those example tokens and the summary token.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the index-weighted item choice fill helpers.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "fillChooseWeightedByIndex"`
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
