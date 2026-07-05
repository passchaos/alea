# S4-M179 Accessor-Weighted Choice Pointer Iterators

Result: passed.

Purpose: add repeated weighted const-pointer iterator facades for item-derived
weights. Local Rust `rand` exposes `choose_weighted_iter(..., |item| weight)`,
where callers provide a closure over each item. S4-M178 added explicit weight
slice iterators; this milestone adds the item-accessor form.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/slice.rs` exposes
  `IndexedRandom::choose_weighted_iter`;
- the weight function maps each item reference to a weight;
- the iterator repeatedly returns item references with replacement.

Alea keeps this Zig-native with comptime item weight functions and explicit
allocator cleanup for owned reusable weighted choices.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.chooseWeightedIterBy`;
- `seq.chooseWeightedIterByFrom`;
- `seq.chooseWeightedIterByChecked`;
- `seq.chooseWeightedIterByCheckedFrom`.

Semantics:

- validates item-derived weights once before iteration;
- builds an owned `WeightedChoice` and streams repeated `*const T` values;
- returned iterators must be deinitialized;
- all-zero or empty effective weights return `null` for optional facades and
  `error.EmptyInput` for checked facades;
- invalid weights and allocation failure return errors without consuming
  randomness.

Focused tests verify facade/direct `WeightedChoice.initBy(...).iterFrom` stream
shape for `ScalarPrng` and `DefaultPrng`, `fill` behavior, single-positive
no-consume behavior, all-zero optional/checked behavior, invalid-weight
no-consume behavior, and allocation failure handling.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints a `weighted by iter fill` row.
- `tools/examplecheck.zig` verifies that example source token.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe accessor-weighted repeated pointer streams.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "accessor weighted choice iterator"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked accessor-weighted pointer-stream ergonomics
gap only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
