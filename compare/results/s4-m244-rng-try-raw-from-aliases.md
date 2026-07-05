# S4-M244 Rng Try Raw From Aliases

Result: passed.

Purpose: add direct-source try-shaped raw helpers to the `Rng` facade
namespace. Local Rust `rand_core::TryRng` exposes `try_next_u64`,
`try_next_u32`, and `try_fill_bytes`; S4-M243 added facade and engine method
aliases, while this milestone adds `From` helpers that can dispatch against a
source value directly.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_core-0.10.1/src/lib.rs`
  exposes `TryRng::try_next_u64`, `try_next_u32`, and `try_fill_bytes`;
- Alea `Rng` convention exposes direct-source `From` helpers for raw,
  probability, range, value, sampler, and fill APIs, so try-shaped raw helpers
  should follow the same adoption pattern.

## Alea API Added

`src/rng.zig` now exposes:

- `Rng.tryNextU64From(source)`;
- `Rng.tryNextU32From(source)`;
- `Rng.tryFillBytesFrom(source, out)`.

Semantics:

- `tryNextU64From` dispatches to source `tryNextU64`, then `tryNext`, then
  infallible `next` fallback;
- `tryNextU32From` dispatches to source `tryNextU32` when available, otherwise
  derives high 32 bits from `tryNextU64From`;
- `tryFillBytesFrom` dispatches to source `tryFillBytes` when available,
  otherwise falls back to infallible byte fill;
- fallible source errors propagate through Zig error unions.

## Adoption and Documentation

- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `compare/results/linux-no-known-gaps-audit.md`, the
  active-goal audit, and `core-rand-coverage.md` describe the aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M245.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "rng direct try raw aliases propagate source failures"`
- `zig test src/root.zig --test-filter "rng facade covers scalar APIs"`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked direct-source try-shaped raw RNG
naming/discoverability gap only. It does not resolve S4-M11's
exact/default-compatible dense SIMD normal/exponential blocker, does not add a
new architecture/runtime runner, and is not whole-goal completion evidence.
