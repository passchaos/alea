# S4-M239 Full-State fromRng/fork Seeding

Result: passed.

Purpose: strengthen S4-M238's Rust-discoverable `fromRng` / `fork` aliases so
multi-word engines consume enough seed material for their target state/key
instead of collapsing the source RNG to one `u64`. Local Rust
`SeedableRng::from_rng` fills the target seed buffer from the source RNG; this
milestone brings Alea direct-engine child construction closer to that behavior
while retaining Zig-native engine state shapes.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_core-0.10.1/src/seedable_rng.rs`
  implements `SeedableRng::from_rng` by filling the target seed buffer from the
  source RNG;
- the same file implements `fork` by delegating to `from_rng(self)`;
- Alea engines expose direct state/key shapes, so full-state `fromRng` can
  consume the target number of `u64` words without adding Rust trait machinery.

## Alea Behavior Strengthened

`src/engines/*.zig` now uses full target seed material for direct-engine
`fromRng(source)` and `fork()`:

- `SplitMix64`: 1 `u64` word;
- `Wyhash64`: 1 `u64` word, stored as direct state via `fromState`;
- `Pcg64`: 2 `u64` words via `initTwo(seed, stream)`;
- `Alea4x64`: 4 `u64` words as direct lane state;
- `Xoshiro256`: 4 `u64` words as direct state, with all-zero state remapped via
  `init(0)`;
- `Xoshiro256PlusPlus`: 4 `u64` words as direct state, with all-zero state
  remapped via `init(0)`;
- `ChaCha`: 4 `u64` words written little-endian into the 32-byte key.

`Seed.fromRng(source)` intentionally remains one `u64` word because `Seed`
itself is one `u64` state value.

## Adoption and Documentation

- `docs/core-guide.md` now documents that `Seed.fromRng` consumes one `u64`,
  while engine `fromRng` / `fork` consume enough `u64` material for the target
  engine.
- `compare/results/s4-m238-engine-fromrng-fork-aliases.md` was corrected to
  state the full-seed-material behavior for the public aliases.
- `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` record this strengthening.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M240.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "engine fromRng and fork aliases consume full seed material"`
- `zig build run-reproducible-streams`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone strengthens seeded child construction semantics only. It does
not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
