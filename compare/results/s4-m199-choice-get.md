# S4-M199 Reusable Choice Item Lookup

Result: passed.

Purpose: add optional item lookup to reusable unweighted and weighted choices.
Alea already exposed checked `itemAt` plus optional probability/weight
diagnostics; S4-M199 adds null-on-missing `get` helpers for callers who want to
inspect reusable sampler populations without error plumbing.

## Local Reference

Local Rust `rand`'s slice distribution keeps its input slice and uses slice
`get` during sampling to guard against out-of-range indexes. Alea does not copy
Rust trait mechanics, but `Choice` / `WeightedChoice` now expose an explicit
Zig-native `get` method that mirrors slice `get` safety and the optional
diagnostics style already used for `IndexVec.get`, `weight`, and `probability`.

Relevant local Rust source:

- `/home/passchaos/Work/rand/src/distr/slice.rs`

## Alea API Added

`src/seq.zig` now exposes:

- `Choice.get`;
- `WeightedChoice.get`.

Semantics:

- returns `?*const T`;
- returns a pointer to the item for valid indexes;
- returns `null` out of bounds;
- preserves existing checked `itemAt` behavior and all sampling stream shapes.

Focused tests verify in-range pointers and out-of-range `null` behavior for
both reusable unweighted and weighted choices.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints a `Choice.get(2)=... missing=true`
  row.
- `examples/weighted_sampling.zig` prints a
  `WeightedChoice.get(2)=... missing=true` row.
- `tools/examplecheck.zig` verifies both example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the optional item lookup.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M200.

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
