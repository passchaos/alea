# S4-M222 IndexVec intoVec Alias

Result: passed.

Purpose: add `IndexVec.intoVec()` as a Rust-discoverable consuming alias for
Alea's existing `IndexVec.intoOwnedSlice()`. Local Rust `IndexVec::into_vec`
returns an owned `Vec<usize>`; Alea already had the equivalent consuming owned
`[]usize` conversion with explicit allocator ownership, and S4-M222 adds the
Rust-discoverable spelling without changing ownership rules.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/index.rs` exposes
  `IndexVec::into_vec(self) -> Vec<usize>`;
- Rust widens compact backing into platform `usize` output when needed;
- Alea's `IndexVec.intoOwnedSlice(allocator)` already performs the equivalent
  Zig-owned conversion.

## Alea API Added

`src/seq.zig` now exposes:

- `IndexVec.intoVec`.

Semantics:

- consumes the `IndexVec` and returns an owned `[]usize`;
- transfers native `usize` backing without copying;
- widens compact `u32` backing to `usize`, frees the compact backing on success,
  and preserves allocation-failure behavior;
- is an alias for `intoOwnedSlice`, keeping Zig allocator ownership explicit.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `IndexVec.intoVec: ...`.
- `tools/examplecheck.zig` verifies the example source token.
- `docs/api-reference.md` lists the new public symbol.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the alias.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M223.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "index vec consuming owned conversions"`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked `IndexVec` naming/discoverability gap only.
It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
