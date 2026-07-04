# S4-M123 Iterator Sample-Fill Aliases

Result: passed.

Purpose: make Alea's caller-owned iterator reservoir sampling discoverable under
terminology matching local Rust `IteratorRandom::sample_fill`. Alea already had
`sampleIteratorInto*` helpers; this milestone adds explicit `sampleIteratorFill*`
aliases.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/iterator.rs`:

- `IteratorRandom::sample_fill(rng, buf)` fills a caller-owned buffer with a
  reservoir sample and returns the number of values written;
- deprecated `choose_multiple_fill` forwards to `sample_fill`.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.sampleIteratorFill`;
- `seq.sampleIteratorFillFrom`;
- `seq.sampleIteratorFillChecked`;
- `seq.sampleIteratorFillCheckedFrom`.

These are Zig-native aliases for the existing `sampleIteratorInto*` reservoir
buffer helpers. Focused tests verify facade/direct stream parity, short-stream
partial fills, checked short-stream no-consume behavior, and zero-length behavior
through the underlying implementation.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `sampleIteratorFillFrom`.
- `tools/examplecheck.zig` verifies that example token.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the sample-fill aliases.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig build test`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked API discoverability gap only. It does not
resolve S4-M11's exact/default-compatible dense SIMD normal/exponential blocker,
does not add a new architecture/runtime runner, and is not whole-goal completion
evidence.
