# S4-M238 Engine fromRng/fork Aliases

Result: passed.

Purpose: add Rust-discoverable seeded-from-RNG and fork aliases. Local Rust
`rand_core::SeedableRng` exposes `from_rng` and `fork`; Alea already had
deterministic `Seed`, `seedFromU64`, and `fromSeed` workflows. This milestone
adds Zig-native aliases that consume one `u64` seed draw from an existing
generator and then use the target engine's normal deterministic constructor.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_core-0.10.1/src/seedable_rng.rs`
  exposes `SeedableRng::from_rng` and `SeedableRng::fork`;
- the same file documents using a master PRNG to seed child PRNGs and warns
  about correlations when the source and child algorithms are related;
- Alea keeps `Seed.mix` / `Seed.stream` as the primary named-stream workflow,
  while `fromRng` / `fork` provide Rust-discoverable deterministic child
  construction for direct-engine users.

## Alea API Added

`src/seed.zig` now exposes:

- `Seed.fromRng(source)`.

`src/engines/*.zig` now exposes `fromRng(source)` and `fork()` on:

- `SplitMix64`;
- `Wyhash64`;
- `Alea4x64`;
- `Xoshiro256`;
- `Xoshiro256PlusPlus`;
- `Pcg64`;
- `ChaCha`.

Semantics:

- `Seed.fromRng(source)` consumes one `source.next()` draw and stores it as
  seed state;
- `Engine.fromRng(source)` consumes one `source.next()` draw and forwards it to
  the engine's normal deterministic `u64` constructor;
- `engine.fork()` delegates to `Engine.fromRng(&engine)`, consuming one seed
  draw from the parent;
- this milestone is naming/discoverability only and does not change `Seed.mix`,
  `Seed.stream`, or existing engine output snapshots.

## Adoption and Documentation

- `examples/reproducible_streams.zig` prints
  `engine fromRng alias next: ...` and `fork child next: ...`.
- `tools/examplecheck.zig` verifies the reproducible-streams example source
  tokens.
- `docs/api-reference.md` lists the new `Seed` and engine public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M239.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "engine fromRng and fork aliases consume one seed draw"`
- `zig build run-reproducible-streams`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked seeded-from-RNG and fork
naming/discoverability gap only. It does not resolve S4-M11's
exact/default-compatible dense SIMD normal/exponential blocker, does not add a
new architecture/runtime runner, and is not whole-goal completion evidence.
