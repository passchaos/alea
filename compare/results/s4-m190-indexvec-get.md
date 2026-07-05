# S4-M190 IndexVec Checked Positional Lookup

Result: passed.

Purpose: add `IndexVec.get()` as a checked positional lookup for sampled index
vectors. Local Rust `rand` exposes `IndexVec::index`, which panics on an
out-of-range position through slice indexing. Alea now keeps the Rust-discoverable
`index()` alias from S4-M189 and adds a Zig-native optional checked lookup for
callers that prefer explicit bounds handling.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/index.rs` exposes
  `IndexVec::index(&self, index: usize) -> usize`, implemented via backing slice
  indexing.

Alea's `IndexVec.at()` and `IndexVec.index()` remain fast unchecked positional
lookups. `IndexVec.get()` exceeds the Rust baseline by returning `null` for an
out-of-range position instead of trapping/panicking.

## Alea API Added

`src/seq.zig` now exposes:

- `IndexVec.get`.

Semantics:

- returns `?usize`;
- returns the same sampled index as `at(position)` / `index(position)` for
  valid positions;
- returns `null` when `position >= len()`;
- works for both compact `u32` and native `usize` backings;
- does not change ownership, validation, or iterator behavior.

Focused tests verify in-range values against stable sampled-index snapshots and
out-of-range `null` behavior.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `IndexVec.index(0)` / `at(0)` and an
  out-of-range `get(len)=null` diagnostic.
- `tools/examplecheck.zig` verifies the example source token.
- `docs/api-reference.md` lists the new public symbol.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the checked lookup.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M191.

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

This milestone closes an unblocked IndexVec checked-access ergonomics gap only.
It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
