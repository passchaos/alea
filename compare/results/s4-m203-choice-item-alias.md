# S4-M203 Reusable Choice Checked Item Alias

Result: passed.

Purpose: add checked `item()` aliases to reusable unweighted and weighted
choices. Alea already exposed checked `itemAt` and optional `get`; S4-M203 adds
a shorter, Rust-discoverable checked item lookup name while preserving existing
Zig-native APIs.

## Local Reference

Local Rust slice and sequence workflows use item/index access naming that is
easy to discover from a reusable sampler context. Alea does not copy Rust trait
mechanics, but adding `item()` mirrors the recent `IndexVec.index` and
`Choice.get` style: keep the original Zig-native helper, add a concise alias
for users scanning for item lookup.

Relevant local Rust source:

- `/home/passchaos/Work/rand/src/distr/slice.rs`
- `/home/passchaos/Work/rand/src/seq/index.rs`

## Alea API Added

`src/seq.zig` now exposes:

- `Choice.item`;
- `WeightedChoice.item`.

Semantics:

- returns the same `*const T` pointer as `itemAt(index)` for valid indexes;
- returns `error.InvalidParameter` out of bounds;
- preserves optional `get`, existing `itemAt`, probability/weight diagnostics,
  and sampling stream behavior.

Focused tests verify valid pointer equality and out-of-range error behavior for
both `Choice` and `WeightedChoice`.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `Choice.item(2)=...`.
- `examples/weighted_sampling.zig` prints `WeightedChoice.item(2)=...`.
- `tools/examplecheck.zig` verifies both example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the checked item aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M204.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "choice sampler"`
- `zig test src/root.zig --test-filter "weighted choice sampler"`
- `zig build run-sequence-sampling`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked reusable-choice diagnostics ergonomics gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
