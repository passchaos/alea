# S4-M166 Rng Choice Arrays

Result: passed.

Purpose: add fixed-size repeated with-replacement value and pointer choice
arrays to `Rng`. Before this milestone, `Rng` had one-shot choice helpers,
caller-owned fill helpers, and heap-owned `choose*Batch` helpers, but no direct
stack-friendly `[N]T`, `[N]*const T`, or `[N]*T` repeated choice arrays. The
existing `seq.chooseArray*` helpers are no-replacement slice samples, so they do
not cover the same repeated with-replacement semantics.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/slice.rs` exposes slice choice and repeated
  choice workflows through `IndexedRandom` / `IndexedMutRandom` traits and
  iterator composition;
- Alea already exposes no-replacement fixed-size slice arrays through
  `seq.chooseArray*`, `seq.sampleItemsArray*`, and pointer-array aliases;
- Alea S4-M165 added fixed-size repeated index-choice arrays for `Rng` / `seq`.

This milestone extends the repeated with-replacement, allocation-free fixed
array shape from indexes to values and pointers in the `Rng` namespace while
leaving `seq.chooseArray*` as no-replacement sampling.

## Alea API Added

`src/rng.zig` now exposes:

- `Rng.chooseValueArray`;
- `Rng.chooseValueArrayFrom`;
- `Rng.chooseValueArrayChecked`;
- `Rng.chooseValueArrayCheckedFrom`;
- `Rng.chooseConstPtrArray`;
- `Rng.chooseConstPtrArrayFrom`;
- `Rng.chooseConstPtrArrayChecked`;
- `Rng.chooseConstPtrArrayCheckedFrom`;
- `Rng.choosePtrArray`;
- `Rng.choosePtrArrayFrom`;
- `Rng.choosePtrArrayChecked`;
- `Rng.choosePtrArrayCheckedFrom`.

The value helpers return `[N]T`, the const-pointer helpers return
`[N]*const T`, and the mutable-pointer helpers return `[N]*T`.

Focused tests verify:

- facade and direct-source arrays preserve stream shape for optional and checked
  value, const-pointer, and mutable-pointer helpers;
- empty optional arrays return null without drawing;
- checked zero-length arrays return without validating/drawing;
- checked non-empty arrays reject empty inputs without drawing;
- singleton slices produce deterministic arrays without consuming the random
  stream.

## Adoption and Documentation

- `examples/basic.zig` prints `value choice array`,
  `const pointer choice array`, and `mutable pointer choice array` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the repeated with-replacement fixed value/pointer array semantics.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "collection helpers preserve direct stream shape"`
- `zig test src/root.zig --test-filter "invalid facade choice helpers"`
- `zig test src/root.zig --test-filter "single-item choice helpers"`
- `zig build run-basic`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked `Rng` repeated choice stack-output ergonomics
gap only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
