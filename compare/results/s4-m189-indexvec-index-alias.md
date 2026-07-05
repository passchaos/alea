# S4-M189 IndexVec Index Alias

Result: passed.

Purpose: add `IndexVec.index()` as a Rust-discoverable positional lookup alias
for Alea's existing `IndexVec.at()`. This improves local `rand` comparison
ergonomics without removing the Zig-native `at` spelling.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/index.rs` exposes
  `IndexVec::index(&self, index: usize) -> usize`, returning the sampled index
  stored at that position.

Alea already had equivalent behavior through `IndexVec.at(position)`. S4-M189
adds the Rust-discoverable alias while preserving `at` for existing Zig users.

## Alea API Added

`src/seq.zig` now exposes:

- `IndexVec.index`.

Semantics:

- returns exactly the same value as `IndexVec.at(position)`;
- works for both compact `u32` and native `usize` backings;
- does not change ownership, validation, or iterator behavior.

Focused tests verify the alias against stable sampled-index snapshots.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints an `IndexVec.index(0)` row beside
  `at(0)`.
- `tools/examplecheck.zig` verifies that example source token.
- `docs/api-reference.md` lists the new public symbol.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the alias.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M190.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "index vec"`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked IndexVec API discoverability gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
