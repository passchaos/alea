# S4-M227 Bernoulli fromRatio Aliases

Result: passed.

Purpose: add Rust-discoverable ratio constructor aliases to scalar and vector
Bernoulli samplers. Local Rust `rand::distr::Bernoulli` exposes
`Bernoulli::from_ratio(numerator, denominator)` for exact numerator-in-
denominator construction. Alea keeps Zig-native `initRatio` / `newRatio` and
adds `fromRatio` aliases for users coming from Rust while preserving Zig
camelCase naming.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/distr/bernoulli.rs` exposes
  `Bernoulli::from_ratio(numerator, denominator)`;
- Rust rejects `denominator == 0` or `numerator > denominator`;
- S4-M225 already exposed `Bernoulli.new` / `newRatio` and vector equivalents.

## Alea API Added

`src/distributions.zig` now exposes:

- `Bernoulli.fromRatio`;
- `VectorBernoulli(VectorType).fromRatio`.

Semantics:

- scalar `fromRatio` mirrors scalar `initRatio`;
- vector `fromRatio` mirrors vector `initRatio`;
- invalid ratio errors are unchanged;
- scalar/vector moment, fill, sampling, and stream behavior are unchanged.

## Adoption and Documentation

- `examples/discrete_distributions.zig` prints
  `Bernoulli.fromRatio(1,4): ...`.
- `tools/examplecheck.zig` verifies the example source token.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M228.

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

This milestone closes an unblocked Bernoulli ratio-constructor naming and
discoverability gap only. It does not resolve S4-M11's exact/default-compatible
dense SIMD normal/exponential blocker, does not add a new architecture/runtime
runner, and is not whole-goal completion evidence.
