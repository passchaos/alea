# S4-M230 Rng randomBool/randomRatio Aliases

Result: passed.

Purpose: add Rust-discoverable probability helper aliases to the `Rng`
facade. Local Rust `rand::RngExt` exposes `random_bool(p)` and
`random_ratio(numerator, denominator)` for one-shot boolean draws. Alea keeps
Zig-native `chance` / `ratio` and adds camelCase `randomBool` / `randomRatio`
aliases for users coming from Rust.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/rng.rs` exposes `RngExt::random_bool(p)`;
- the same file exposes `RngExt::random_ratio(numerator, denominator)`;
- `/home/passchaos/Work/rand/src/lib.rs` exposes crate-level
  `random_bool(p)` / `random_ratio(numerator, denominator)` shorthands;
- Rust rejects invalid probabilities or ratios through panic paths, while Alea
  keeps explicit checked error-returning helpers.

## Alea API Added

`src/rng.zig` now exposes:

- `Rng.randomBool`;
- `Rng.randomBoolFrom`;
- `Rng.randomBoolChecked`;
- `Rng.randomBoolCheckedFrom`;
- `Rng.randomRatio`;
- `Rng.randomRatioFrom`;
- `Rng.randomRatioChecked`;
- `Rng.randomRatioCheckedFrom`.

Semantics:

- `randomBool` mirrors `chance`;
- `randomBoolFrom` mirrors `chanceFrom`;
- `randomBoolChecked` mirrors `chanceChecked`;
- `randomBoolCheckedFrom` mirrors `chanceCheckedFrom`;
- `randomRatio` mirrors `ratio`;
- `randomRatioFrom` mirrors `ratioFrom`;
- `randomRatioChecked` mirrors `ratioChecked`;
- `randomRatioCheckedFrom` mirrors `ratioCheckedFrom`;
- invalid probability/ratio errors are unchanged;
- deterministic no-consume behavior for degenerate probability/ratio cases is
  unchanged.

## Adoption and Documentation

- `examples/basic.zig` prints `randomBool p=.25: ...` and
  `randomRatio 3/8: ...`.
- `tools/examplecheck.zig` verifies those example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M231.

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

This milestone closes an unblocked `Rng` probability-helper
naming/discoverability gap only. It does not resolve S4-M11's
exact/default-compatible dense SIMD normal/exponential blocker, does not add a
new architecture/runtime runner, and is not whole-goal completion evidence.
