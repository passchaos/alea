# S4-M193 Optional Weighted Sampler Probability Lookup

Result: passed.

Purpose: add optional single-probability lookup helpers to static weighted
samplers. Alea already exposed checked/error-returning `probabilityAt` and bulk
probability exports; S4-M193 adds null-on-missing `probability()` helpers that
match the optional ergonomics introduced for `weight()` in S4-M191.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs` exposes
  `WeightedIndex::weight(index) -> Option<X>` for single-index diagnostics;
- local Rust does not expose a direct probability helper on `WeightedIndex`, so
  this is a Zig-native above-Rust diagnostic that complements Alea's existing
  `probabilityAt` / `probabilitiesInto` surface.

## Alea API Added

`src/distributions.zig` now exposes:

- `AliasTable.probability`.

`src/seq.zig` now exposes:

- `WeightedChoice.probability`.

Semantics:

- returns `?f64`;
- mirrors `probabilityAt(index)` for valid indexes;
- returns `null` out of bounds;
- preserves existing `probabilityAt`, `probabilities`, `probabilitiesInto`,
  `weight`, `weightAt`, `weightIter`, and bulk weight export behavior.

Focused tests verify in-range probabilities and out-of-range `null` behavior for
`AliasTable` and `WeightedChoice`.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `alias probability(2)=... missing=true`
  and `WeightedChoice.probability(2)=... missing=true` rows.
- `tools/examplecheck.zig` verifies those example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe optional probability lookup.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M194.

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
