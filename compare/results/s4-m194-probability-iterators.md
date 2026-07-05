# S4-M194 Weighted Sampler Probability Iterators

Result: passed.

Purpose: add lazy probability iterators to static weighted samplers. Alea already
exposed checked `probabilityAt`, optional `probability`, and bulk
`probabilities` / `probabilitiesInto` exports. S4-M194 adds allocation-free
iterator diagnostics for normalized probabilities, mirroring the S4-M192 weight
iterator shape.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs` exposes lazy
  iterator-style diagnostics through `WeightedIndex::weights()`;
- local Rust does not expose direct probability iterators on `WeightedIndex`, so
  this is a Zig-native above-Rust diagnostic complementing Alea's probability
  accessors and exports.

## Alea API Added

`src/distributions.zig` now exposes:

- `AliasTable.ProbabilityIterator`;
- `AliasTable.probabilityIter`;
- `AliasTable.ProbabilityIterator.next`;
- `AliasTable.ProbabilityIterator.remaining`;
- `AliasTable.ProbabilityIterator.len`;
- `AliasTable.ProbabilityIterator.fill`.

`src/seq.zig` now exposes:

- `WeightedChoice.probabilityIter`.

Semantics:

- streams normalized probabilities in index order;
- `next()` returns `null` after the final probability;
- `remaining()` and `len()` report exact remaining counts;
- `fill()` drains up to the destination length and returns the filled count;
- preserves existing checked `probabilityAt`, optional `probability`, and bulk
  probability export behavior.

Focused tests verify `next`, exact remaining counts, `len`, caller-buffer fill,
and exhaustion for `AliasTable` and `WeightedChoice`.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `alias probabilityIter fill` and
  `WeightedChoice.probabilityIter fill` rows.
- `tools/examplecheck.zig` verifies those example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe lazy probability iterators.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M195.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "alias table exposes totals"`
- `zig test src/root.zig --test-filter "weighted choice sampler maps alias indexes"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked weighted-sampler probability diagnostics gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
