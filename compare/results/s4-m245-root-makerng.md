# S4-M245 Root makeRng Helper

Result: passed.

Purpose: add a Rust-discoverable generic system-entropy engine constructor.
Local Rust `rand::make_rng<R: SeedableRng>()` constructs a seedable RNG from
thread/system entropy. Alea already had engine-specific secure constructors;
this milestone adds a Zig-native generic root helper.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/lib.rs` exposes
  `pub fn make_rng<R: SeedableRng>() -> R`;
- local Rust uses thread RNG when available or `SysRng` otherwise;
- Alea maps this to explicit Zig `makeRng(Engine, io)` to preserve engine type
  clarity and Zig 0.16 `std.Io` entropy flow.

## Alea API Added

`src/root.zig` now exposes:

- `makeRng(comptime Engine: type, io: std.Io) !Engine`.

Semantics:

- callers explicitly provide the target exported engine type;
- `makeRng` draws system entropy through `std.Io.randomSecure`;
- scalar engines use 8 bytes;
- `Pcg64` uses 16 bytes;
- `Alea4x64`, `Xoshiro256`, `Xoshiro256PlusPlus`, and `ChaCha` use 32 bytes /
  the engine seed length;
- construction delegates through each engine's fixed byte-seed constructor.

## Adoption and Documentation

- `docs/api-reference.md` lists the new root constructor.
- `docs/core-guide.md`, `README.md`,
  `compare/results/reproducibility-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the helper.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M246.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "makeRng constructs exported engines from system entropy"`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked generic entropy-constructor
naming/discoverability gap only. It does not resolve S4-M11's
exact/default-compatible dense SIMD normal/exponential blocker, does not add a
new architecture/runtime runner, and is not whole-goal completion evidence.
