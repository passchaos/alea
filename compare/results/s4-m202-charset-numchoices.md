# S4-M202 Charset Count Diagnostics

Result: passed.

Purpose: add `Charset.numChoices()` as a count diagnostic for custom ASCII
charsets. Alea already exposed `Charset.len`; S4-M202 adds the same
Rust-discoverable naming style used by reusable `Choice.numChoices`, so string
generation and reusable choice diagnostics use consistent count terminology.

## Local Reference

Local Rust `rand` exposes `distr::slice::Choose::num_choices()` for reusable
slice choices. Alea's `Charset` is a Zig-native byte-oriented string-generation
sampler rather than a Rust trait port, but exposing `numChoices()` gives the
same count-discovery affordance for custom alphabets.

Relevant local Rust source:

- `/home/passchaos/Work/rand/src/distr/slice.rs`

## Alea API Added

`src/ascii.zig` now exposes:

- `Charset.numChoices`.

Semantics:

- returns `usize`;
- mirrors `Charset.len()`;
- does not allocate;
- does not consume randomness;
- preserves existing `bytesValue`, `len`, checked `byteAt`, optional `get`,
  probability, probability-iterator, and string-generation behavior.

Focused tests verify that predefined `Alphanumeric.numChoices()` matches both
the byte-set length and `len()`.

## Adoption and Documentation

- `examples/string_generation.zig` prints `custom charset numChoices: ...`.
- `tools/examplecheck.zig` verifies that example source token.
- `docs/api-reference.md` lists the new public symbol.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the count diagnostic.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M203.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "ascii"`
- `zig build run-string-generation`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked charset diagnostics ergonomics gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
