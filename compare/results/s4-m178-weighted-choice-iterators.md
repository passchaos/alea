# S4-M178 Weighted Choice Pointer Iterators

Result: passed.

Purpose: add repeated weighted const-pointer iterator facades for generic slice
weights. Local Rust `rand` exposes `choose_weighted_iter`, returning an iterator
that repeatedly samples weighted slice elements with replacement. Alea already
had one-shot/fill/batch/fixed-array weighted choices and reusable weighted index
iterators; this milestone adds the direct pointer-stream ergonomics.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/slice.rs` exposes
  `IndexedRandom::choose_weighted_iter`;
- it validates weights once through `WeightedIndex`, then returns an iterator
  that yields repeated references into the source slice;
- invalid weights report `WeightError`, while an all-zero/empty effective
  distribution does not produce samples.

Alea keeps this Zig-native: `WeightedChoice.iterFrom` is a borrowed reusable
stream, while `seq.chooseWeightedIterFrom` owns the reusable weighted choice and
requires explicit `deinit`.

## Alea API Added

`src/seq.zig` now exposes:

- `WeightedChoice.iter`;
- `WeightedChoice.iterFrom`;
- `WeightedChoice.ownedIter`;
- `WeightedChoice.ownedIterFrom`;
- `WeightedChoice.Iterator`;
- `WeightedChoice.Iterator.next`;
- `WeightedChoice.Iterator.nextValue`;
- `WeightedChoice.Iterator.fill`;
- `WeightedChoice.Iterator.deinit`;
- `seq.chooseWeightedIter`;
- `seq.chooseWeightedIterFrom`;
- `seq.chooseWeightedIterChecked`;
- `seq.chooseWeightedIterCheckedFrom`.

Semantics:

- `WeightedChoice.iter*` borrows an existing reusable weighted choice and streams
  repeated `*const T` values;
- `seq.chooseWeightedIter*` validates and builds an owned `WeightedChoice`, then
  returns a stream that must be deinitialized;
- all-zero or empty weights return `null` for optional facades and
  `error.EmptyInput` for checked facades;
- length mismatch, non-finite/negative weights, and allocation failure return
  errors without consuming randomness.

Focused tests verify facade/direct stream-shape parity for `ScalarPrng` and
`DefaultPrng`, fill helpers, single-positive no-consume behavior, empty/all-zero
optional and checked behavior, invalid no-consume behavior, and allocation
failure handling.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints a `seq.chooseWeightedIterFrom fill`
  row.
- `tools/examplecheck.zig` verifies that example source token.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe repeated weighted pointer streams.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "weighted choice iterator"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked repeated weighted pointer-stream ergonomics
gap only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
