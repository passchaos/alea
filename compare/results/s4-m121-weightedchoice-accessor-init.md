# S4-M121 WeightedChoice Accessor Construction and Update

Result: passed.

Purpose: make reusable weighted choice workflows accept item-derived weights
without requiring callers to maintain a parallel weight slice. This complements
S4-M115 through S4-M120 accessor-based one-shot, no-replacement, caller-owned,
and fixed-size workflows, and maps to local Rust `choose_weighted_iter(...,
|item| ...)` repeated weighted-reference ergonomics.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs`:

- `choose_weighted_iter(&mut rng, |item| ...)` builds a weighted index
  distribution from an item accessor and repeatedly samples references.

Alea already has reusable `WeightedChoice` samplers with value/pointer/index
samples, fills, owned batches, diagnostics, and updates. S4-M121 adds the
missing accessor-based construction and update path for those reusable samplers.

## Alea API Added

`src/seq.zig` now exposes nested methods on `seq.WeightedChoice(T, Weight)`:

- `WeightedChoice.initBy(allocator, items, weightFn)`;
- `WeightedChoice.updateBy(weightFn)`.

Both use a comptime `fn (*const T) Weight` accessor. `initBy` validates empty
items before building a temporary weight slice. `updateBy` preserves the prior
alias table when derived weights are invalid or allocation fails, matching the
existing `WeightedChoice.update` table-safety contract.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints:
  - `WeightedChoice.initBy sample`
  - `WeightedChoice.updateBy indices`
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists the new public methods.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe reusable accessor-weighted choice workflows.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig build test`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked reusable sequence ergonomics gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
