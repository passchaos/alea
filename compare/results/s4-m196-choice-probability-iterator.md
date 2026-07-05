# S4-M196 Choice Probability Iterator

Result: passed.

Purpose: add a lazy probability iterator to reusable unweighted choices. Alea
already exposed `Choice.probabilityAt`, bulk `probabilities` /
`probabilitiesInto`, and S4-M195 optional `Choice.probability`; S4-M196 adds an
allocation-free iterator diagnostic that mirrors the weighted sampler probability
iterator shape.

## Local Reference

Local Rust `rand` exposes `distr::slice::Choose::num_choices()` for reusable
slice choices but does not expose direct probability iteration. This is a
Zig-native above-Rust diagnostic that keeps reusable unweighted and weighted
sampler introspection consistent.

## Alea API Added

`src/seq.zig` now exposes:

- `Choice.ProbabilityIterator`;
- `Choice.probabilityIter`;
- `Choice.ProbabilityIterator.next`;
- `Choice.ProbabilityIterator.remaining`;
- `Choice.ProbabilityIterator.len`;
- `Choice.ProbabilityIterator.fill`.

Semantics:

- streams uniform probabilities in index order;
- `next()` returns `null` after the final probability;
- `remaining()` and `len()` report exact remaining counts;
- `fill()` drains up to the destination length and returns the filled count;
- preserves existing checked `probabilityAt`, optional `probability`, and bulk
  probability export behavior.

Focused tests verify `next`, exact remaining counts, `len`, caller-buffer fill,
and exhaustion for `Choice`.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints a `Choice.probabilityIter fill` row.
- `tools/examplecheck.zig` verifies that example source token.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the iterator.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M197.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "choice sampler repeatedly samples"`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked reusable-choice probability diagnostics gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
