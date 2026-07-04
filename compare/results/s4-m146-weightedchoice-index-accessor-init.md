# S4-M146 WeightedChoice Index Accessor Construction/Update

Result: passed.

Purpose: build and refresh reusable `WeightedChoice` samplers from a comptime
index-weight function. S4-M121 added item-accessor construction/update;
S4-M143 through S4-M145 added one-shot, caller-owned, and allocation-returning
index-weighted item choices. This milestone brings the same length/index-weight
ergonomics to the reusable alias-table sampler.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs` and
`/home/passchaos/Work/rand/src/seq/index.rs`:

- `IndexedRandom::choose_weighted_iter(rng, |item| ...)` builds a reusable
  weighted-index distribution over positions for repeated reference selection;
- `index::sample_weighted(rng, length, |index| ..., amount)` demonstrates the
  length/index-weight accessor shape.

Alea already supports reusable `WeightedChoice.initBy` / `updateBy` for
item-derived weights. This milestone avoids the remaining parallel-weight-slice
step when weights are naturally functions of positions.

## Alea API Added

`src/seq.zig` now exposes:

- `WeightedChoice.initByIndex`;
- `WeightedChoice.updateByIndex`.

Both helpers allocate a temporary weight slice from `0..items.len` and build or
refresh the underlying alias table. Empty item slices return `error.EmptyInput`.
Invalid negative, NaN, infinite, all-zero, or overflowing totals return
`error.InvalidWeight` through the alias table path. Failed updates preserve the
existing sampler table.

Focused tests verify:

- index-weighted construction preserves `len`, total weight, and reconstructed
  per-index weights;
- sampling excludes zero-weight positions and can reach positive positions;
- `updateByIndex` refreshes the table and single-positive updates become
  deterministic without consuming randomness;
- empty and invalid initialization fail;
- invalid updates and allocation-failure updates preserve the existing table.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `WeightedChoice.initByIndex sample`
  and `WeightedChoice.updateByIndex values` rows.
- `tools/examplecheck.zig` verifies those example tokens and the summary token.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe `WeightedChoice.initByIndex` / `updateByIndex`.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "weighted choice index accessor"`
- `zig build test`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked weighted sequence ergonomics gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
