# S4-M129 Seq Shuffle Aliases

Result: passed.

Purpose: make full in-place slice shuffling discoverable in the `seq`
namespace alongside `partialShuffle` and `partialShuffleSplit`. Alea already had
`Rng.shuffle` / `Rng.shuffleFrom`; this milestone adds explicit `seq.shuffle*`
aliases matching local Rust `SliceRandom::shuffle` terminology.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs`:

- `SliceRandom::shuffle(rng)` shuffles a mutable slice in place;
- `SliceRandom::partial_shuffle(rng, amount)` is the partial selected/rest
  companion.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.shuffle`;
- `seq.shuffleFrom`.

These are Zig-native aliases for `Rng.shuffleFrom`, keeping full shuffles next
to `seq.partialShuffle*` sequence helpers without duplicating the shuffle
algorithm.

Focused tests verify:

- facade/direct stream-shape parity against `Rng.shuffleFrom`;
- direct-source alias parity;
- empty and singleton slices do not consume randomness.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `shuffleFrom deck head`.
- `tools/examplecheck.zig` verifies that example token.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the `seq.shuffle` aliases.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "seq shuffle aliases"`
- `zig build test`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked sequence API discoverability gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
