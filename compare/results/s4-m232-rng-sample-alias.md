# S4-M232 Rng sample Alias

Result: passed.

Purpose: add Rust-discoverable one-shot sampler facade aliases. Local Rust
`rand::RngExt` exposes `rng.sample(distribution)` for sampling once from a
distribution. Alea already exposed reusable sampler methods (`sampler.sample`)
and repeated facade helpers (`sampleIter`, `sampleBatch`); this milestone adds
the scalar facade spelling for users coming from Rust.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/rng.rs` exposes
  `RngExt::sample(distribution)`;
- the same file exposes `sample_iter(distribution)` for repeated draws, which
  Alea already covered with `sampleIter`;
- Alea sampler structs already expose `sample(rng)` / `sampleFrom(source)`.

## Alea API Added

`src/rng.zig` now exposes:

- `Rng.sample`;
- `Rng.sampleFrom`.

Semantics:

- `Rng.sample(T, sampler)` delegates through the same generic sampler dispatch
  used by `sampleIter` / `sampleBatch`;
- `Rng.sampleFrom(source, T, sampler)` uses the direct-source sampler dispatch;
- samplers with `sample(rng, T)` / `sampleFrom(source, T)` signatures and
  samplers with `sample(rng)` / `sampleFrom(source)` signatures remain
  supported;
- stream shape is preserved against direct sampler calls.

## Adoption and Documentation

- `examples/basic.zig` prints `sample die: ...`.
- `tools/examplecheck.zig` verifies the basic example source token.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M233.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "value and sampler iterators produce unbounded samples"`
- `zig build run-basic`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked `Rng` sampler facade
naming/discoverability gap only. It does not resolve S4-M11's
exact/default-compatible dense SIMD normal/exponential blocker, does not add a
new architecture/runtime runner, and is not whole-goal completion evidence.
