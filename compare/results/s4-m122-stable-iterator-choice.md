# S4-M122 Stable Iterator Choice Aliases

Result: passed.

Purpose: make Alea's iterator choice stability discoverable under terminology
matching local Rust `IteratorRandom::choose_stable`. Alea's iterator choice is
already reservoir-based and independent of Rust-style size hints; this milestone
adds explicit stable aliases so users looking for local Rust's stable iterator
choice can find the Zig-native API.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/iterator.rs`:

- `choose` may use `Iterator::size_hint` and can change RNG call shape/result
  across iterator adapters;
- `choose_stable` intentionally makes the selected index depend only on the
  iterator length and RNG stream.

Zig iterators used by Alea expose only `next`, so `chooseIteratorFrom` already
uses one reservoir-sampling draw policy independent of size hints. S4-M122 adds
stable names as aliases to this existing behavior.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.chooseIteratorStable`;
- `seq.chooseIteratorStableFrom`;
- `seq.chooseIteratorStableChecked`;
- `seq.chooseIteratorStableCheckedFrom`.

Focused tests verify facade/direct stream-shape parity with `chooseIteratorFrom`
and empty checked/optional no-consume behavior.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `chooseIteratorStableFrom`.
- `tools/examplecheck.zig` verifies that example token.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the stable iterator choice aliases.

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
