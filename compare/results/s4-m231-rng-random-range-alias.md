# S4-M231 Rng randomRange Aliases

Result: passed.

Purpose: add Rust-discoverable scalar range helper aliases to the `Rng`
facade. Local Rust `rand::RngExt` exposes `random_range(range)` for one-shot
integer and floating-point ranges. Alea keeps explicit Zig-native half-open and
inclusive helpers and adds camelCase `randomRange*` aliases for users coming
from Rust.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/rng.rs` exposes `RngExt::random_range(range)`;
- `/home/passchaos/Work/rand/src/lib.rs` exposes crate-level
  `random_range(range)`;
- Rust supports half-open and inclusive ranges through range syntax; Alea keeps
  those semantics explicit as `randomRange` and `randomRangeAtMost`.

## Alea API Added

`src/rng.zig` now exposes:

- `Rng.randomRange`;
- `Rng.randomRangeFrom`;
- `Rng.randomRangeChecked`;
- `Rng.randomRangeCheckedFrom`;
- `Rng.randomRangeAtMost`;
- `Rng.randomRangeAtMostFrom`;
- `Rng.randomRangeAtMostChecked`;
- `Rng.randomRangeAtMostCheckedFrom`.

Semantics:

- `randomRange` mirrors half-open integer/float range sampling;
- `randomRangeFrom` mirrors the direct-source half-open helper;
- `randomRangeChecked` mirrors checked half-open integer/float range sampling;
- `randomRangeCheckedFrom` mirrors the direct-source checked half-open helper;
- `randomRangeAtMost` mirrors inclusive integer range sampling;
- `randomRangeAtMostFrom` mirrors the direct-source inclusive integer helper;
- `randomRangeAtMostChecked` mirrors checked inclusive integer range sampling;
- `randomRangeAtMostCheckedFrom` mirrors the direct-source checked inclusive
  integer helper;
- invalid range errors are unchanged;
- deterministic no-consume behavior for collapsed/degenerate ranges is
  unchanged.

## Adoption and Documentation

- `examples/range_sampling.zig` prints `randomRange die=...` and
  `randomRangeAtMost die=...`.
- `tools/examplecheck.zig` verifies those range example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M232.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "rng facade covers scalar APIs"`
- `zig build run-range-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked `Rng` scalar range naming/discoverability gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
