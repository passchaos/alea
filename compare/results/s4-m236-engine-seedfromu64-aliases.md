# S4-M236 Engine seedFromU64 Aliases

Result: passed.

Purpose: add Rust-discoverable deterministic `u64` seed constructor aliases to
direct engines. Local Rust `rand_core::SeedableRng` exposes
`seed_from_u64`; Alea engines already had Zig-native `init(seed)` or
`initFromU64(seed)` constructors.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_core-0.10.1/src/seedable_rng.rs`
  exposes `SeedableRng::seed_from_u64`;
- `/home/passchaos/Work/rand/src/rngs/xoshiro256plusplus.rs`,
  `/home/passchaos/Work/rand/src/rngs/std.rs`, and
  `/home/passchaos/Work/rand/src/rngs/small.rs` expose or document
  `seed_from_u64` for deterministic PRNG construction;
- Alea direct engines are commonly used where benchmark shape matters, so
  constructor naming should be discoverable without requiring a facade wrapper.

## Alea API Added

`src/engines/*.zig` now exposes `seedFromU64(seed)` on:

- `SplitMix64`;
- `Wyhash64`;
- `Alea4x64`;
- `Xoshiro256`;
- `Xoshiro256PlusPlus`;
- `Pcg64`;
- `ChaCha`.

Semantics:

- `seedFromU64` mirrors the existing deterministic `u64` constructor for each
  engine;
- for `ChaCha`, `seedFromU64` mirrors the existing `initFromU64`;
- this milestone is a naming/discoverability alias only and does not alter seed
  derivation or output snapshots.

## Adoption and Documentation

- `examples/reproducible_streams.zig` prints
  `engine seedFromU64 alias next: ...`.
- `tools/examplecheck.zig` verifies the reproducible-streams example source
  token.
- `docs/api-reference.md` lists the new engine public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M237.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "engine seedFromU64 aliases mirror constructors"`
- `zig build run-reproducible-streams`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked direct-engine constructor
naming/discoverability gap only. It does not resolve S4-M11's
exact/default-compatible dense SIMD normal/exponential blocker, does not add a
new architecture/runtime runner, and is not whole-goal completion evidence.
