# S4-M180 Index-Weighted Choice Pointer Iterators

Result: passed.

Purpose: add repeated weighted const-pointer iterator facades for length/index
weight accessors. S4-M178 covered explicit weight slices, S4-M179 covered item
accessor weights, and this milestone completes the matching repeated pointer
stream shape for existing index-weighted workflows.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/slice.rs` exposes
  `IndexedRandom::choose_weighted_iter`, returning repeated references with
  replacement from a weighted slice;
- local Alea already exceeds Rust by supporting length/index-weight accessors
  across one-shot, fill, batch, fixed-array, and reusable construction paths.

This milestone applies the same repeated pointer-stream ergonomics to Alea's
index-weighted accessor surface.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.chooseWeightedIterByIndex`;
- `seq.chooseWeightedIterByIndexFrom`;
- `seq.chooseWeightedIterByIndexChecked`;
- `seq.chooseWeightedIterByIndexCheckedFrom`.

Semantics:

- validates index-derived weights once before iteration;
- builds an owned `WeightedChoice` with `initByIndex` and streams repeated
  `*const T` values;
- returned iterators must be deinitialized;
- all-zero weights return `null` for optional facades and `error.EmptyInput` for
  checked facades;
- invalid weights and allocation failure return errors without consuming
  randomness.

Focused tests verify facade/direct `WeightedChoice.initByIndex(...).iterFrom`
stream shape for `ScalarPrng` and `DefaultPrng`, `fill` behavior,
single-positive no-consume behavior, all-zero optional/checked behavior,
invalid-weight no-consume behavior, and allocation failure handling.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints a `weighted index-weight iter fill`
  row.
- `tools/examplecheck.zig` verifies that example source token.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe index-weighted repeated pointer streams.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "index-weighted choice iterator"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked index-weighted pointer-stream ergonomics gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
