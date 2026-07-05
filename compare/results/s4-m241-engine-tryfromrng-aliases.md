# S4-M241 Engine tryFromRng Aliases

Result: passed.

Purpose: add Rust-discoverable fallible seeded-from-RNG constructors. Local Rust
`rand_core::SeedableRng::try_from_rng` fills a target seed from a potentially
fallible RNG; Alea now exposes Zig-native `tryFromRng` helpers using a
`source.tryNext() !u64` contract.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_core-0.10.1/src/seedable_rng.rs`
  exposes `SeedableRng::try_from_rng`;
- the same file describes `try_from_rng` as the fallible equivalent of
  `from_rng`;
- Alea mirrors the naming and fallibility while preserving Zig-native error
  propagation and direct engine state/key construction.

## Alea API Added

`src/seed.zig` now exposes:

- `Seed.tryFromRng(source)`.

`src/engines/*.zig` now exposes `tryFromRng(source)` on:

- `SplitMix64`;
- `Wyhash64`;
- `Alea4x64`;
- `Xoshiro256`;
- `Xoshiro256PlusPlus`;
- `Pcg64`;
- `ChaCha`.

Semantics:

- the source must expose `tryNext() !u64`;
- `Seed.tryFromRng` consumes one fallible word;
- scalar engines consume one word, `Pcg64` consumes two words, and 32-byte
  state/key engines consume four words;
- source errors propagate and construction fails before returning a child;
- successful construction matches the strengthened full-state `fromRng`
  behavior.

## Adoption and Documentation

- `docs/api-reference.md` lists the new `Seed` and engine public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M242.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "engine tryFromRng aliases propagate source failures"`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked fallible seeded-from-RNG constructor
naming/discoverability gap only. It does not resolve S4-M11's
exact/default-compatible dense SIMD normal/exponential blocker, does not add a
new architecture/runtime runner, and is not whole-goal completion evidence.
