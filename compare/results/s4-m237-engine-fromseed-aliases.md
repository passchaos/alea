# S4-M237 Engine fromSeed Aliases

Result: passed.

Purpose: add Rust-discoverable `fromSeed` constructor aliases to direct
engines. Local Rust `rand_core::SeedableRng` exposes `from_seed`; Alea uses
the Zig-native `Seed` type with `mix` and `stream` derivation for stable named
streams. This milestone bridges that naming without changing seed derivation.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_core-0.10.1/src/seedable_rng.rs`
  exposes `SeedableRng::from_seed`;
- `/home/passchaos/Work/rand/src/rngs/xoshiro256plusplus.rs` and
  `/home/passchaos/Work/rand/src/rngs/std.rs` implement `from_seed` for
  deterministic engines;
- Alea `Seed` values already carry stable `u64` state, so a Zig-native
  `fromSeed(seed)` alias maps to each engine's existing `Seed.state`-backed
  constructor.

## Alea API Added

`src/engines/*.zig` now exposes `fromSeed(seed)` on:

- `SplitMix64`;
- `Wyhash64`;
- `Alea4x64`;
- `Xoshiro256`;
- `Xoshiro256PlusPlus`;
- `Pcg64`;
- `ChaCha`.

Semantics:

- `fromSeed(seed)` mirrors the existing deterministic constructor using
  `seed.state`;
- for `ChaCha`, `fromSeed(seed)` mirrors `initFromU64(seed.state)`;
- this is a naming/discoverability alias only and does not change `Seed.mix`,
  `Seed.stream`, `seedFromU64`, or output snapshots.

## Adoption and Documentation

- `examples/reproducible_streams.zig` prints
  `engine fromSeed alias next: ...`.
- `tools/examplecheck.zig` verifies the reproducible-streams example source
  token.
- `docs/api-reference.md` lists the new engine public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M238.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "engine fromSeed aliases mirror Seed constructors"`
- `zig build run-reproducible-streams`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked direct-engine `Seed` constructor
naming/discoverability gap only. It does not resolve S4-M11's
exact/default-compatible dense SIMD normal/exponential blocker, does not add a
new architecture/runtime runner, and is not whole-goal completion evidence.
