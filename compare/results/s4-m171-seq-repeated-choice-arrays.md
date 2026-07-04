# S4-M171 Seq Repeated Choice Arrays

Result: passed.

Purpose: add explicit fixed-size repeated with-replacement value, const-pointer,
and mutable-pointer choice arrays in the `seq` namespace. Before this milestone,
`seq` exposed one-shot choices, caller-owned fills, allocation-returning batches,
and repeated index arrays, while `Rng` exposed direct repeated value/pointer
arrays. The older `seq.chooseArray` / `seq.choosePtrArray` /
`seq.chooseMutPtrArray` names are no-replacement slice samples, so S4-M171 adds
`chooseRepeated*Array` names for the with-replacement side without changing those
existing semantics.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/slice.rs` exposes `IndexedRandom::choose`
  and `IndexedMutRandom` / `SliceRandom` helpers;
- repeated by-value or pointer/reference choices in Rust are assembled through
  repeated `choose` calls, iterators, or `collect`, not direct fixed-size stack
  arrays;
- Rust `IndexedRandom::sample_array` is no-replacement; Alea mirrors that with
  `sampleItemsArray` / `chooseArray` and keeps the new repeated API explicitly
  named.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.chooseRepeatedValueArray`;
- `seq.chooseRepeatedValueArrayFrom`;
- `seq.chooseRepeatedValueArrayChecked`;
- `seq.chooseRepeatedValueArrayCheckedFrom`;
- `seq.chooseRepeatedConstPtrArray`;
- `seq.chooseRepeatedConstPtrArrayFrom`;
- `seq.chooseRepeatedConstPtrArrayChecked`;
- `seq.chooseRepeatedConstPtrArrayCheckedFrom`;
- `seq.chooseRepeatedPtrArray`;
- `seq.chooseRepeatedPtrArrayFrom`;
- `seq.chooseRepeatedPtrArrayChecked`;
- `seq.chooseRepeatedPtrArrayCheckedFrom`.

The value helpers return `[N]T`, const-pointer helpers return `[N]*const T`,
and mutable-pointer helpers return `[N]*T`.

Focused tests verify:

- facade and direct-source arrays preserve `Rng.choose*ArrayFrom` stream shape
  for value/const-pointer/mutable-pointer arrays;
- zero-length checked arrays return before validating or drawing;
- empty optional arrays return `null` without drawing;
- checked empty inputs return `error.EmptyInput` without drawing;
- singleton inputs fill deterministic arrays without consuming the random
  stream;
- mutable-pointer arrays point into the caller-provided mutable slice.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints
  `seq.chooseRepeatedValueArrayFrom items`,
  `seq.chooseRepeatedConstPtrArrayFrom items`, and
  `seq.chooseRepeatedPtrArrayFrom updated scores` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the repeated choice fixed-array semantics and distinguish them from
  no-replacement `chooseArray` / `sample*Array` helpers.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "seq repeated choice arrays"`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked `seq` repeated stack-output ergonomics gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
