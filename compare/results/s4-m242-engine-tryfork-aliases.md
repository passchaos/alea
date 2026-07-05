# S4-M242 Engine tryNext/tryFork Aliases

Result: passed.

Purpose: add Rust-discoverable fallible raw-draw and self-fork aliases on
direct engines. Local Rust `rand_core::TryRng` exposes `try_next_u64`, and
`SeedableRng` exposes `try_fork` as the fallible equivalent of `fork`,
delegating to `try_from_rng(self)`. Alea now exposes Zig-native `tryNext()` and
`tryFork()` spellings.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_core-0.10.1/src/lib.rs`
  exposes `TryRng::try_next_u64`;
- `/home/passchaos/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_core-0.10.1/src/seedable_rng.rs`
  exposes `SeedableRng::try_fork`;
- the same file implements `try_fork` by delegating to `try_from_rng(self)`;
- S4-M241 already added engine `tryFromRng(source)`, so `tryFork()` is the
  direct self-fork alias completing this part of the seedable-RNG naming set.

## Alea API Added

`src/engines/*.zig` now exposes `tryNext()` and `tryFork()` on:

- `SplitMix64`;
- `Wyhash64`;
- `Alea4x64`;
- `Xoshiro256`;
- `Xoshiro256PlusPlus`;
- `Pcg64`;
- `ChaCha`.

Semantics:

- `engine.tryNext()` is an infallible engine's error-union raw draw wrapper over
  `next()`;
- `engine.tryFork()` delegates to `Engine.tryFromRng(&engine)`;
- successful `tryFork` consumes the same full target seed material as
  `fork` / `tryFromRng(self)`;
- errors propagate through Zig's normal error-union path for sources whose
  `tryNext()` can fail.

## Adoption and Documentation

- `docs/api-reference.md` lists the new engine public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M243.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "engine fromRng and fork aliases consume full seed material"`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked fallible fork naming/discoverability gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
