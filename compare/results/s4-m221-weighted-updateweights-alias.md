# S4-M221 Weighted updateWeights Aliases

Result: passed.

Purpose: add Rust-discoverable ordered partial-update naming across Alea's
weighted samplers. Local Rust `WeightedIndex::update_weights` names the partial
update operation. Alea keeps Zig-native `updateMany` as the primary ordered
partial-update spelling, while S4-M221 adds `updateWeights` aliases for users
coming from the local Rust API.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs` exposes
  `WeightedIndex::update_weights(&mut self, new_weights: &[(usize, &X)])`;
- S4-M219 and S4-M220 already added Alea's ordered partial-update semantics;
- S4-M221 closes the remaining naming/discoverability gap.

## Alea API Added

`src/distributions.zig` now exposes:

- `AliasTable.updateWeights`;
- `WeightedTree.updateWeights`;
- `WeightedIntTree.updateWeights`.

`src/seq.zig` now exposes:

- `WeightedChoice.updateWeights`.

Semantics:

- each alias delegates to the corresponding `updateMany` implementation;
- ordered index validation, invalid-weight handling, overflow handling, and
  failed-update state preservation are identical to `updateMany`;
- the alias is intentionally camelCase to match Alea's public Zig API style
  while remaining discoverable from Rust `update_weights`.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints updateWeights total-weight rows for
  `AliasTable`, `WeightedChoice`, `WeightedTree`, and `WeightedIntTree`.
- `tools/examplecheck.zig` verifies those example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the alias.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M222.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "updateWeights"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked weighted-update naming/discoverability gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
