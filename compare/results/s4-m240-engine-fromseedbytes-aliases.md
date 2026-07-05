# S4-M240 Engine fromSeedBytes Aliases

Result: passed.

Purpose: add Rust-discoverable fixed byte-array seed constructors to direct
engines. Local Rust `rand_core::SeedableRng::from_seed` constructs PRNGs from
engine-specific byte-array seed types; Alea already exposes Zig-native
`Seed`-based and `u64` constructors. This milestone adds `fromSeedBytes` for
callers who want the byte-array seed shape directly.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_core-0.10.1/src/seedable_rng.rs`
  defines `SeedableRng::from_seed(seed: Self::Seed)`;
- `/home/passchaos/Work/rand/src/rngs/xoshiro256plusplus.rs` implements
  `from_seed([u8; 32])` by reading little-endian state words and remapping
  all-zero state through `seed_from_u64(0)`;
- Alea keeps `Seed.mix` / `Seed.stream` as the high-level named-stream API, but
  direct engines can now accept fixed byte arrays where that shape is useful.

## Alea API Added

`src/engines/*.zig` now exposes:

- `SplitMix64.fromSeedBytes([8]u8)`;
- `Wyhash64.fromSeedBytes([8]u8)`;
- `Pcg64.fromSeedBytes([16]u8)`;
- `Alea4x64.fromSeedBytes([32]u8)`;
- `Xoshiro256.fromSeedBytes([32]u8)`;
- `Xoshiro256PlusPlus.fromSeedBytes([32]u8)`;
- `ChaCha.fromSeedBytes([ChaCha.seed_length]u8)`.

Semantics:

- byte seeds are interpreted as little-endian `u64` words;
- scalar engines use one word;
- `Pcg64` uses two words as `initTwo(seed, stream)`;
- `Alea4x64`, `Xoshiro256`, `Xoshiro256PlusPlus`, and `ChaCha` use four
  words / 32 bytes of seed material;
- Xoshiro all-zero byte seeds fall back through `init(0)`.

## Adoption and Documentation

- `examples/reproducible_streams.zig` prints
  `engine fromSeedBytes alias next: ...`.
- `tools/examplecheck.zig` verifies the reproducible-streams example source
  token.
- `docs/api-reference.md` lists the new engine public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit,
  `compare/results/reproducibility-matrix.md`, and `core-rand-coverage.md`
  describe the aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M241.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "engine fromSeedBytes aliases mirror byte seed constructors"`
- `zig build run-reproducible-streams`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked byte-array seed constructor
naming/discoverability gap only. It does not resolve S4-M11's
exact/default-compatible dense SIMD normal/exponential blocker, does not add a
new architecture/runtime runner, and is not whole-goal completion evidence.
