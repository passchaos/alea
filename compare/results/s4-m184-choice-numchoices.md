# S4-M184 Choice Count Diagnostics

Result: passed.

Purpose: add random-choice-count diagnostics to reusable unweighted and weighted
choice samplers. Local Rust `rand::distr::slice::Choose` exposes
`num_choices()`, which makes the distribution's selectable population count
discoverable. Alea already exposed `len`; this milestone adds the more
random-choice-oriented name while preserving Zig-native naming.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/distr/slice.rs` exposes
  `Choose::num_choices()`;
- the method returns the number of selectable slice items.

Alea's `Choice` and `WeightedChoice` are reusable sequence samplers rather than
Rust distribution clones, so the matching Zig API is `numChoices()`.

## Alea API Added

`src/seq.zig` now exposes:

- `Choice.numChoices`;
- `WeightedChoice.numChoices`.

Semantics:

- returns the count of selectable items;
- matches `len()` for both reusable choice types;
- works for unweighted and weighted reusable samplers.

Focused tests verify `numChoices()` on `Choice` and `WeightedChoice` alongside
existing `len()` diagnostics.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints a `Choice.numChoices` row.
- `examples/weighted_sampling.zig` prints a `WeightedChoice.numChoices` row.
- `tools/examplecheck.zig` verifies both example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe choice count diagnostics.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "choice sampler repeatedly"`
- `zig test src/root.zig --test-filter "weighted choice sampler maps"`
- `zig build run-sequence-sampling`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked reusable choice diagnostics gap only. It does
not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
