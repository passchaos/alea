# S4-M162 Choice Index Arrays

Result: passed.

Purpose: add fixed-size repeated index arrays to reusable unweighted choices.
`Choice` already exposed single index samples, caller-owned index fills, owned
index batches, value/pointer fills, value/pointer owned batches, and repeated
pointer iterators. After S4-M161, reusable weighted choices also exposed
stack-friendly fixed-size index arrays, leaving the unweighted reusable sampler
as the remaining asymmetric API surface.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/slice.rs` exposes indexed slice choice and
  sample workflows through Rust traits;
- `/home/passchaos/Work/rand/src/seq/index.rs` exposes reusable-style index
  sampling algorithms for distinct index samples;
- Alea `seq.sampleArray*`, `Choice.indices*`, and `WeightedChoice.indexArray*`
  already provide the nearby allocation-free or allocation-returning shapes.

This milestone keeps the Zig API matrix consistent without copying Rust trait
machinery: reusable `Choice` can now directly return stack-friendly repeated
with-replacement index arrays.

## Alea API Added

`src/seq.zig` now exposes on `Choice(T)`:

- `Choice.indexArray`;
- `Choice.indexArrayFrom`;
- `Choice.indexArrayU32`;
- `Choice.indexArrayU32Checked`;
- `Choice.indexArrayU32From`;
- `Choice.indexArrayU32CheckedFrom`.

The `usize` helpers return `[N]usize`. The compact `u32` helpers return
`Error![N]u32`, inheriting the same population-size validation as
`fillIndicesU32From`.

Focused tests verify:

- fixed `usize` arrays match caller-owned `fillIndicesFrom` under identical
  seeds;
- fixed `u32` arrays match caller-owned `fillIndicesU32From` under identical
  seeds;
- facade and direct-source paths preserve stream shape;
- zero-length fixed arrays return without sampling;
- single-item choices return deterministic arrays without consuming the random
  stream.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `Choice.indexArrayFrom` and
  `Choice.indexArrayU32From` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe fixed-size reusable choice index arrays.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "Choice index arrays"`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked reusable unweighted choice stack-output
ergonomics gap only. It does not resolve S4-M11's exact/default-compatible dense
SIMD normal/exponential blocker, does not add a new architecture/runtime runner,
and is not whole-goal completion evidence.
