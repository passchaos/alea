# S4-M165 Fixed Repeated Index-Choice Arrays

Result: passed.

Purpose: add fixed-size repeated with-replacement index choice arrays to `Rng`
and `seq`. Alea already exposed one-shot `chooseIndex*`, caller-owned
`fillChooseIndex*`, and heap-owned `chooseIndex*Batch` helpers. It also exposed
`sampleArray*`, but those are no-replacement fixed arrays, not repeated
with-replacement choices.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/slice.rs` exposes indexed slice choice and
  repeated choice workflows through Rust traits and iterator composition;
- `/home/passchaos/Work/rand/src/seq/index.rs` exposes distinct-index sampling
  algorithms, which correspond to Alea `sampleArray*` rather than repeated
  with-replacement choice;
- Alea `Choice.indexArray*` now covers reusable sampler repeated index arrays,
  leaving top-level `Rng` / `seq` fixed repeated index arrays as the missing
  direct API shape.

This milestone keeps the semantics explicit: `chooseIndexArray*` is repeated
with replacement; `sampleArray*` remains no-replacement sampling.

## Alea API Added

`src/rng.zig` now exposes:

- `Rng.chooseIndexArray`;
- `Rng.chooseIndexArrayFrom`;
- `Rng.chooseIndexArrayChecked`;
- `Rng.chooseIndexArrayCheckedFrom`;
- `Rng.chooseIndexArrayU32`;
- `Rng.chooseIndexArrayU32From`;
- `Rng.chooseIndexArrayU32Checked`;
- `Rng.chooseIndexArrayU32CheckedFrom`.

`src/seq.zig` exposes matching aliases:

- `seq.chooseIndexArray`;
- `seq.chooseIndexArrayFrom`;
- `seq.chooseIndexArrayChecked`;
- `seq.chooseIndexArrayCheckedFrom`;
- `seq.chooseIndexArrayU32`;
- `seq.chooseIndexArrayU32From`;
- `seq.chooseIndexArrayU32Checked`;
- `seq.chooseIndexArrayU32CheckedFrom`.

The `usize` helpers return `[N]usize`. The compact helpers return `[N]u32` for
`u32` population lengths.

Focused tests verify:

- facade and direct-source arrays preserve stream shape for optional and checked
  `usize` and compact `u32` helpers;
- empty optional arrays return null without drawing;
- checked zero-length arrays return without validating/drawing;
- checked non-empty arrays reject empty populations without drawing;
- singleton populations produce all-zero arrays without consuming the random
  stream;
- `seq` aliases preserve `seq`-style `EmptyInput` errors while forwarding the
  successful stream shape to `Rng`.

## Adoption and Documentation

- `examples/basic.zig` prints `index choice array` and
  `u32 index choice array` rows for `Rng`.
- `examples/sequence_sampling.zig` prints `seq.chooseIndexArrayFrom` and
  `seq.chooseIndexArrayU32From` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the repeated with-replacement fixed index array semantics.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "index choice"`
- `zig build run-basic`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked top-level repeated-index-choice stack-output
ergonomics gap only. It does not resolve S4-M11's exact/default-compatible dense
SIMD normal/exponential blocker, does not add a new architecture/runtime runner,
and is not whole-goal completion evidence.
