# S4-M233 Rng randomValue Aliases

Result: passed.

Purpose: add Rust-discoverable structured-value aliases to the `Rng` facade.
Local Rust `rand::RngExt` exposes `rng.random::<T>()` for `StandardUniform`
sampling. Alea already has Zig-native `value(T)` / `valueChecked(T)`; this
milestone adds `randomValue*` spellings while keeping `random()` reserved for
`std.Random` interoperability.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/rng.rs` exposes `RngExt::random<T>()`;
- Rust `random<T>()` samples via `StandardUniform`;
- Alea `Rng.random()` already returns `std.Random`, so `randomValue` is the
  Zig-native non-conflicting discoverability alias.

## Alea API Added

`src/rng.zig` now exposes:

- `Rng.randomValue`;
- `Rng.randomValueFrom`;
- `Rng.randomValueChecked`;
- `Rng.randomValueCheckedFrom`.

Semantics:

- `randomValue` mirrors `value`;
- `randomValueFrom` mirrors `valueFrom`;
- `randomValueChecked` mirrors `valueChecked`;
- `randomValueCheckedFrom` mirrors `valueCheckedFrom`;
- empty-enum checked errors and no-consume behavior are unchanged.

## Adoption and Documentation

- `examples/basic.zig` prints `randomValue u16: ...`.
- `tools/examplecheck.zig` verifies the basic example source token.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M234.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "rng facade covers scalar APIs"`
- `zig build run-basic`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked `Rng` structured-value naming/discoverability
gap only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
