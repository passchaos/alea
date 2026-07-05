# S4-M235 Engine Raw Aliases

Result: passed.

Purpose: extend S4-M234's Rust-discoverable raw RNG naming from the `Rng`
facade to direct engine workflows. Local Rust `rand_core::Rng` exposes
`next_u64`, `next_u32`, and `fill_bytes`; Alea engines already expose
Zig-native `next()` and, for byte-capable engines, `fill(out)`.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_core-0.10.1/src/lib.rs`
  exposes `Rng::next_u64`, `Rng::next_u32`, and `Rng::fill_bytes`;
- `/home/passchaos/Work/rand/src/rngs/xoshiro256plusplus.rs` derives
  `try_next_u32` from the high 32 bits of `try_next_u64`;
- Alea direct-engine APIs are often used for benchmark-sensitive paths, so raw
  naming should be discoverable without wrapping in `Rng`.

## Alea API Added

`src/engines/*.zig` now exposes:

- `nextU64` / `nextU32` on `SplitMix64`, `Wyhash64`, `Alea4x64`,
  `Xoshiro256`, `Xoshiro256PlusPlus`, `Pcg64`, and `ChaCha`;
- `fillBytes` on byte-capable engines: `Wyhash64`, `Alea4x64`,
  `Xoshiro256`, `Xoshiro256PlusPlus`, `Pcg64`, and `ChaCha`.

Semantics:

- `nextU64` mirrors each engine's `next`;
- `nextU32` consumes one `u64` draw and returns its high 32 bits;
- `fillBytes` mirrors each engine's existing `fill` byte-stream method;
- `SplitMix64` remains a seeding/scalar helper and does not grow a byte-fill
  API in this milestone.

## Adoption and Documentation

- `examples/reproducible_streams.zig` prints `engine raw aliases: ...`.
- `tools/examplecheck.zig` verifies the reproducible-streams example source
  tokens.
- `docs/api-reference.md` lists the new engine public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the direct-engine aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M236.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "engine raw aliases preserve stream shape"`
- `zig build run-reproducible-streams`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked direct-engine raw naming/discoverability gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
