# S4-M135 Accessor-Weighted Choice Fills

Result: passed.

Purpose: make repeated with-replacement weighted choices from item-derived
weights available without first constructing a reusable `WeightedChoice` table.
Alea already had one-shot accessor choices from S4-M115 and no-replacement
accessor samples from S4-M116/S4-M117; this milestone adds caller-owned repeated
choice fills for value, const-pointer, and mutable-pointer outputs.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs`:

- `IndexedRandom::choose_weighted(rng, |item| ...)` builds a weighted-index
  distribution over item-derived weights and returns a selected reference;
- `IndexedMutRandom::choose_weighted_mut(rng, |item| ...)` provides the mutable
  reference variant;
- `IndexedRandom::choose_weighted_iter(rng, |item| ...)` returns an iterator for
  repeated with-replacement weighted choices.

Rust's iterator form can be adapted with `.take(n)` to fill caller-owned output.
Alea now provides direct Zig caller-buffer helpers for that workflow, preserving
the existing reusable `WeightedChoice.initBy` path for workloads that want an
alias table across many calls.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.fillChooseWeightedBy`;
- `seq.fillChooseWeightedByFrom`;
- `seq.fillChooseWeightedByChecked`;
- `seq.fillChooseWeightedByCheckedFrom`;
- `seq.fillChooseWeightedConstPtrBy`;
- `seq.fillChooseWeightedConstPtrByFrom`;
- `seq.fillChooseWeightedConstPtrByChecked`;
- `seq.fillChooseWeightedConstPtrByCheckedFrom`;
- `seq.fillChooseWeightedPtrBy`;
- `seq.fillChooseWeightedPtrByFrom`;
- `seq.fillChooseWeightedPtrByChecked`;
- `seq.fillChooseWeightedPtrByCheckedFrom`.

Optional output buffers (`?T`, `?*const T`, `?*T`) represent all-zero or empty
weight input with `null` entries. Checked output buffers reject those paths with
`error.EmptyInput`. All helpers validate item-derived weights before drawing;
negative, non-finite, or overflowing totals return `error.InvalidWeight`.

Focused tests verify:

- value, const-pointer, and mutable-pointer output buffers;
- facade/direct stream-shape parity for `ScalarPrng` and `DefaultPrng`;
- zero-length destination no-consume behavior before validating weights;
- empty/all-zero optional no-consume behavior;
- checked empty/all-zero no-consume behavior;
- single-positive no-consume behavior;
- invalid-weight no-consume behavior.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `weighted by value fill`,
  `weighted by const ptr fill`, and `weighted by mut ptr fill` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the accessor-weighted fill helpers.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "fillChooseWeightedBy"`
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
