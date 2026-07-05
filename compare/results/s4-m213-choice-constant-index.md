# S4-M213 Choice Singleton Constant-Index Diagnostics

Result: passed.

Purpose: add `Choice.constantIndex()` as a reusable unweighted-choice diagnostic
for singleton no-consume sampling paths. `Choice` already returns index 0 for
single-item choices without consuming randomness; S4-M213 exposes that
point-mass index directly and aligns reusable unweighted choices with
`WeightedChoice.constantIndex`.

## Local Reference

Local Rust `rand` exposes `distr::slice::Choose::num_choices()` for reusable
slice choices. Alea already exposes `Choice.numChoices()` for count diagnostics
and `WeightedChoice.constantIndex()` for single-positive weighted choices.
`Choice.constantIndex()` is a Zig-native diagnostic alias for the deterministic
singleton case rather than a Rust trait port.

Relevant local Rust source:

- `/home/passchaos/Work/rand/src/distr/slice.rs`

## Alea API Added

`src/seq.zig` now exposes:

- `Choice.constantIndex`.

Semantics:

- returns `?usize`;
- returns `0` for singleton choices;
- returns `null` for choices with more than one item;
- empty choices cannot be constructed through `Choice.init` and still return
  `null` through optional constructors;
- does not allocate;
- does not consume randomness;
- matches the deterministic no-consume sample/fill path used by singleton
  `Choice`.

Focused tests verify multi-item `null` and singleton `0` behavior alongside the
existing single-item no-consume stream tests.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `Choice.constantIndex: ...` and
  `Choice.single-item constantIndex: ...`.
- `tools/examplecheck.zig` verifies those example source tokens.
- `docs/api-reference.md` lists the new public symbol.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the diagnostic.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M214.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "choice sampler repeatedly samples slice references"`
- `zig test src/root.zig --test-filter "single-item choice sampler does not consume random stream"`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked reusable unweighted-choice diagnostics gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
