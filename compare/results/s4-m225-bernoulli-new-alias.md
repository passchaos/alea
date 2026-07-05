# S4-M225 Bernoulli new Aliases

Result: passed.

Purpose: add Rust-discoverable constructor aliases to scalar and vector
Bernoulli samplers. Local Rust `rand::distr::Bernoulli::new` constructs the
Bernoulli distribution from a probability. Alea keeps Zig-native `init` /
`initRatio` and adds `new` / `newRatio` aliases for users coming from Rust.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/distr/bernoulli.rs` exposes
  `Bernoulli::new(p)`;
- Rust validates probability range during construction;
- Alea already exposed `Bernoulli.init` / `initRatio` and vector equivalents.

## Alea API Added

`src/distributions.zig` now exposes:

- `Bernoulli.new`;
- `Bernoulli.newRatio`;
- `VectorBernoulli(VectorType).new`;
- `VectorBernoulli(VectorType).newRatio`.

Semantics:

- `new` mirrors `init`;
- `newRatio` mirrors `initRatio`;
- invalid probability and ratio errors are unchanged;
- scalar/vector moment and sampling behavior are unchanged.

## Adoption and Documentation

- `examples/discrete_distributions.zig` prints `Bernoulli.new(p=.25): ...`.
- `tools/examplecheck.zig` verifies the example source token.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M226.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "Bernoulli"`
- `zig build run-discrete-distributions`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked Bernoulli constructor naming/discoverability
gap only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
