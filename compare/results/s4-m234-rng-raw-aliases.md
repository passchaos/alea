# S4-M234 Rng Raw Aliases

Result: passed.

Purpose: add Rust-discoverable raw RNG facade aliases. Local Rust
`rand_core::Rng` exposes `next_u64`, `next_u32`, and `fill_bytes`; Alea already
had Zig-native `next()`, `bytes(out)`, and typed `fill(u8, out)`. This
milestone adds discoverable camelCase aliases without changing the existing
engine contract.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_core-0.10.1/src/lib.rs`
  exposes `Rng::next_u64`, `Rng::next_u32`, and `Rng::fill_bytes`;
- `/home/passchaos/Work/rand/src/rngs/xoshiro256plusplus.rs` derives
  `try_next_u32` from the high 32 bits of `try_next_u64`;
- `/home/passchaos/Work/rand/src/rng.rs` documents raw fill APIs alongside
  `RngExt::fill` and higher-level value/distribution helpers.

## Alea API Added

`src/rng.zig` now exposes:

- `Rng.nextU64`;
- `Rng.nextU64From`;
- `Rng.nextU32`;
- `Rng.nextU32From`;
- `Rng.fillBytes`;
- `Rng.fillBytesFrom`.

Semantics:

- `nextU64` mirrors `next`;
- `nextU64From` mirrors `nextFrom`;
- `nextU32` consumes one facade `u64` draw and returns its high 32 bits,
  matching the local Rust xoshiro256 raw-u32 policy while keeping stream
  consumption explicit and stable;
- `nextU32From` dispatches to a direct source `nextU32` where the source exposes
  one, and otherwise falls back to the same high-32-bits policy;
- `fillBytes` mirrors `bytes`;
- `fillBytesFrom` exposes the existing direct-source byte-fill dispatch.

## Adoption and Documentation

- `examples/basic.zig` prints `nextU64 raw: ...`, `nextU32 raw: ...`, and
  `fillBytes raw: ...`.
- `tools/examplecheck.zig` verifies the basic example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M235.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "rng facade covers scalar APIs"`
- `zig test src/root.zig --test-filter "value and iterator helpers preserve direct stream shape"`
- `zig build run-basic`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked raw RNG naming/discoverability gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
