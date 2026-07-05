# S4-M218 Static Weighted Single-Weight Updates

Result: passed.

Purpose: add Zig-native single-weight update helpers to static/reusable weighted
samplers. Local Rust `WeightedIndex::update_weights` accepts an ordered partial
update list and preserves the distribution on invalid input. Alea already had
full-table `AliasTable.update` / `WeightedChoice.update` plus dynamic-tree
`update(index, weight)` paths; S4-M218 fills the static alias-table/reusable
choice single-weight update gap without copying Rust's slice-of-pairs API shape.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs` exposes
  `WeightedIndex::update_weights(&mut self, new_weights: &[(usize, &X)])`;
- the Rust implementation validates ordered indexes, bounds, weights, and
  non-zero total before changing `self`;
- the same Rust type exposes `weight`, `weights`, and `total_weight` diagnostics
  after updates.

Alea's static alias table rebuilds O(1) sampling state, so the Zig API is
`updateAt(index, weight)` for the common one-weight replacement case. Users who
need frequent dynamic O(log n) updates can still use `WeightedTree.update` /
`WeightedIntTree.update`.

## Alea API Added

`src/distributions.zig` now exposes:

- `AliasTable.updateAt`.

`src/seq.zig` now exposes:

- `WeightedChoice.updateAt`.

Semantics:

- rejects out-of-range indexes with `error.InvalidParameter`;
- rejects negative, NaN, infinite, overflowing, or all-zero replacement states
  with `error.InvalidWeight`;
- builds the replacement alias table before swapping state, so invalid input and
  allocation failures leave the previous sampler usable;
- keeps `totalWeight`, `positiveCount`, `constantIndex`, `weight`, `weights`,
  `probability`, and iterator diagnostics consistent after successful updates;
- preserves single-positive no-consume sampling behavior after an update leaves
  one positive weight.

To support exact diagnostics after incremental updates, `AliasTable` stores the
normalized f64 weights used to build alias columns. This also makes
`weightAt` / `weightsInto` exact with respect to the validated build inputs
instead of reconstructing from alias columns.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `alias updateAt totalWeight: ...` and
  `WeightedChoice.updateAt totalWeight: ...`.
- `tools/examplecheck.zig` verifies those example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the new single-weight update helpers.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M219.

## Validation

The relevant validation for this milestone is:

- `zig test src/root.zig --test-filter "updateAt"`
- `zig test src/root.zig --test-filter "alias table exposes totals"`
- `zig test src/root.zig --test-filter "weighted choice sampler maps alias indexes"`
- `zig build run-weighted-sampling`
- `git diff --check`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked weighted-sampler partial-update ergonomics gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
