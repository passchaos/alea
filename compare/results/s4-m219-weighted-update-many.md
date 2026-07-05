# S4-M219 Static Weighted Ordered Partial Updates

Result: passed.

Purpose: extend static/reusable weighted sampler partial updates from the
S4-M218 single-weight `updateAt` shorthand to ordered multi-weight replacement.
Local Rust `WeightedIndex::update_weights` accepts an ordered list of partial
updates, validates the whole list, and leaves the previous distribution intact
on error. S4-M219 adds the equivalent static alias-table/reusable-choice workflow
with Zig-native update records.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs` exposes
  `WeightedIndex::update_weights(&mut self, new_weights: &[(usize, &X)])`;
- that implementation rejects unordered or duplicate indexes, out-of-range
  indexes, invalid weights, and zero-total replacement states before mutating;
- the same Rust type exposes updated `weight`, `weights`, and `total_weight`
  diagnostics after successful partial updates.

Alea keeps `updateAt(index, weight)` as the single-weight shorthand and adds
`updateMany(&.{.{ .index = ..., .weight = ... }, ...})` for ordered partial
updates. This avoids importing Rust tuple/slice API shape while preserving the
important partial-update semantics.

## Alea API Added

`src/distributions.zig` now exposes:

- `AliasTable.Update`;
- `AliasTable.updateMany`.

`src/seq.zig` now exposes:

- `WeightedChoice.Update`;
- `WeightedChoice.updateMany`.

Semantics:

- empty update lists are a no-op;
- update indexes must be in bounds and strictly increasing;
- duplicate or unordered indexes return `error.InvalidParameter`;
- negative, NaN, infinite, overflowing, or all-zero replacement states return
  `error.InvalidWeight`;
- invalid input is validated before allocation when possible, and allocation
  failures leave the previous sampler usable;
- after successful updates, `totalWeight`, `positiveCount`, `constantIndex`,
  `weight`, `weights`, `probability`, and iterator diagnostics reflect the new
  weights.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `alias updateMany totalWeight: ...`
  and `WeightedChoice.updateMany totalWeight: ...`.
- `tools/examplecheck.zig` verifies those example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the ordered partial-update helpers.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M220.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "updateMany"`
- `zig test src/root.zig --test-filter "updateAt"`
- `zig test src/root.zig --test-filter "alias table exposes totals"`
- `zig test src/root.zig --test-filter "weighted choice sampler maps alias indexes"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked weighted-sampler ordered partial-update
ergonomics gap only. It does not resolve S4-M11's exact/default-compatible dense
SIMD normal/exponential blocker, does not add a new architecture/runtime runner,
and is not whole-goal completion evidence.
