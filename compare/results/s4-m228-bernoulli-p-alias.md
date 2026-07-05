# S4-M228 Bernoulli p Aliases

Result: passed.

Purpose: add Rust-discoverable probability lookup aliases to scalar and vector
Bernoulli samplers. Local Rust `rand::distr::Bernoulli` exposes
`Bernoulli::p()` to return the stored success probability. Alea keeps
Zig-native `probability` / `probabilityValue` and adds `p()` aliases for users
coming from Rust.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/distr/bernoulli.rs` exposes
  `Bernoulli::p(&self) -> f64`;
- Rust documents that the returned value may differ slightly from input because
  of precision;
- S4-M225 and S4-M227 already added Bernoulli constructor aliases, leaving the
  Rust-discoverable accessor naming as the next small unblocked gap.

## Alea API Added

`src/distributions.zig` now exposes:

- `Bernoulli.p`;
- `VectorBernoulli(VectorType).p`.

Semantics:

- scalar `p()` mirrors scalar `probability()`;
- vector `p()` mirrors vector `probability()`;
- `probabilityValue()` remains the Zig-descriptive value accessor;
- scalar/vector moment, fill, sampling, and stream behavior are unchanged.

## Adoption and Documentation

- `examples/discrete_distributions.zig` prints `p()=...` in the Bernoulli
  diagnostic line.
- `tools/examplecheck.zig` verifies the example source token.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M229.

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

This milestone closes an unblocked Bernoulli accessor naming/discoverability
gap only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
