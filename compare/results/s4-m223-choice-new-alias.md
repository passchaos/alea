# S4-M223 Choice new Aliases

Result: passed.

Purpose: add Rust-discoverable construction aliases to reusable unweighted
choices. Local Rust `rand::distr::slice::Choose::new` constructs a reusable
slice-choice distribution. Alea already had Zig-native `Choice.init` and
`Choice.initChecked`; S4-M223 adds `Choice.new` / `Choice.newChecked` aliases
without changing the existing API shape.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/distr/slice.rs` exposes
  `Choose::new(slice)`;
- the Rust constructor rejects empty slices;
- Alea's optional `init` and checked `initChecked` already covered the behavior
  with Zig-style naming.

## Alea API Added

`src/seq.zig` now exposes:

- `Choice.new`;
- `Choice.newChecked`.

Semantics:

- `Choice.new(items)` mirrors `Choice.init(items)` and returns `null` for empty
  inputs;
- `Choice.newChecked(items)` mirrors `Choice.initChecked(items)` and returns
  `error.EmptyInput` for empty inputs;
- all existing sampling, diagnostics, and no-consume singleton behavior are
  unchanged.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `Choice.new numChoices: ...`.
- `tools/examplecheck.zig` verifies the example source token.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M224.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "choice sampler repeatedly samples slice references"`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked reusable-choice constructor naming gap only.
It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
