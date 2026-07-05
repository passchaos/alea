# S4-M226 Uniform new Aliases

Result: passed.

Purpose: add Rust-discoverable constructor aliases to scalar and vector Uniform
samplers. Local Rust `rand::distr::Uniform` exposes `Uniform::new(low, high)`
for half-open ranges and `Uniform::new_inclusive(low, high)` for inclusive
ranges. Alea keeps Zig-native `init` / `initInclusive` and adds `new` /
`newInclusive` aliases for users coming from Rust.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/distr/uniform.rs` exposes
  `Uniform::new(low, high)`;
- the same file exposes `Uniform::new_inclusive(low, high)`;
- Rust rejects empty or invalid ranges during construction;
- Alea already exposed `Uniform(T).init` / `initInclusive` and
  `VectorUniform(VectorType).init` / `initInclusive`.

## Alea API Added

`src/distributions.zig` now exposes:

- `Uniform(T).new`;
- `Uniform(T).newInclusive`;
- `VectorUniform(VectorType).new`;
- `VectorUniform(VectorType).newInclusive`.

Semantics:

- scalar `new` mirrors scalar `init`;
- scalar `newInclusive` mirrors scalar `initInclusive`;
- vector `new` mirrors vector `init`;
- vector `newInclusive` mirrors vector `initInclusive`;
- invalid range errors are unchanged;
- moment, fill, sampling, and stream behavior are unchanged.

## Adoption and Documentation

- `examples/range_sampling.zig` prints `Uniform(f64).new`,
  `Uniform(u8).newInclusive`, `VectorUniform(f32x4).new`, and
  `VectorUniform(i32x4).newInclusive` evidence.
- `tools/examplecheck.zig` verifies the range example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M227.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "Uniform"`
- `zig build run-range-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked Uniform constructor naming/discoverability
gap only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
