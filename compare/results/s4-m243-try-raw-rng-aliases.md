# S4-M243 Try Raw RNG Aliases

Result: passed.

Purpose: add Rust-discoverable try-shaped raw RNG aliases. Local Rust
`rand_core::TryRng` exposes `try_next_u64`, `try_next_u32`, and
`try_fill_bytes`; Alea engines are currently infallible, but exposing
error-union wrappers makes fallible-style code and Rust migration terminology
discoverable.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_core-0.10.1/src/lib.rs`
  exposes `TryRng::try_next_u64`, `try_next_u32`, and `try_fill_bytes`;
- local Rust `Rng` derives infallible raw methods from fallible raw methods
  when the error type is `Infallible`;
- Alea mirrors the naming with Zig error unions while preserving the existing
  infallible engine stream shape.

## Alea API Added

`src/rng.zig` now exposes:

- `Rng.tryNextU64`;
- `Rng.tryNextU32`;
- `Rng.tryFillBytes`.

`src/engines/*.zig` now exposes:

- `tryNextU64` / `tryNextU32` on `SplitMix64`, `Wyhash64`, `Alea4x64`,
  `Xoshiro256`, `Xoshiro256PlusPlus`, `Pcg64`, and `ChaCha`;
- `tryFillBytes` on byte-fill-capable engines: `Wyhash64`, `Alea4x64`,
  `Xoshiro256`, `Xoshiro256PlusPlus`, `Pcg64`, and `ChaCha`.

Semantics:

- `tryNextU64` mirrors `nextU64`;
- `tryNextU32` consumes one `tryNext` / `next` draw and returns its high
  32 bits;
- `tryFillBytes` mirrors `fillBytes`;
- all helpers currently return infallibly but use Zig error-union spelling for
  fallible-source compatibility and Rust discoverability.

## Adoption and Documentation

- `docs/api-reference.md` lists the new `Rng` and engine public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the aliases.
- `compare/results/s4-m242-engine-tryfork-aliases.md` was updated to mention
  the full try-shaped raw alias set that supports `tryFork`.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M244.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "engine raw aliases preserve stream shape"`
- `zig test src/root.zig --test-filter "engine fromRng and fork aliases consume full seed material"`
- `zig test src/root.zig --test-filter "rng facade covers scalar APIs"`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked try-shaped raw RNG naming/discoverability gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
