# S4-M209 AliasTable Count Diagnostics

Result: passed.

Purpose: add `AliasTable.numChoices()` as a count diagnostic for static
alias-table weighted samplers. Alea already exposed `AliasTable.len`; S4-M209
adds naming consistent with reusable `Choice.numChoices`, `WeightedChoice.numChoices`,
and `Charset.numChoices`.

## Local Reference

Local Rust `rand` exposes `distr::slice::Choose::num_choices()` for reusable
slice choices. `AliasTable` is Alea's Zig-native static alias-table weighted
sampler, so `numChoices()` is an adoption/discoverability alias rather than a
Rust trait port.

Relevant local Rust source:

- `/home/passchaos/Work/rand/src/distr/slice.rs`

## Alea API Added

`src/distributions.zig` now exposes:

- `AliasTable.numChoices`.

Semantics:

- returns `usize`;
- mirrors `AliasTable.len()`;
- does not allocate;
- does not consume randomness;
- preserves existing static alias-table weight/probability diagnostics, bulk
  exports, iterators, and sampling behavior.

Focused tests verify that `AliasTable.numChoices()` matches `len()`.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `alias numChoices: ...`.
- `tools/examplecheck.zig` verifies that example source token.
- `docs/api-reference.md` lists the new public symbol.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the count diagnostic.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M210.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "alias table exposes totals"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked static weighted-sampler diagnostics gap only.
It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
