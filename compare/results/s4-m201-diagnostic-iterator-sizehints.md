# S4-M201 Diagnostic Iterator Size Hints

Result: passed.

Purpose: add exact `sizeHint()` diagnostics to lazy weight and probability
iterators introduced in recent sampler-inspection milestones. S4-M187 added
size hints to bounded index and sampled iterators; S4-M201 extends that
exact-size iterator ergonomics to diagnostic iterators for static weighted
samplers, reusable choices, and string-generation charsets.

## Local Reference

Local Rust `rand` exposes `Iterator::size_hint` and `ExactSizeIterator::len`
for exact-size sequence iterators, and `WeightedIndex::weights()` returns a lazy
iterator over reconstructed weights. Alea does not copy Rust traits; it exposes
explicit Zig-native `sizeHint()` methods that return exact lower and upper
remaining counts.

Relevant local Rust source:

- `/home/passchaos/Work/rand/src/seq/index.rs`
- `/home/passchaos/Work/rand/src/seq/slice.rs`
- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs`

## Alea API Added

The public diagnostic iterators now expose:

- `AliasTable.WeightIterator.sizeHint`;
- `AliasTable.ProbabilityIterator.sizeHint`;
- `Choice.ProbabilityIterator.sizeHint`;
- `WeightedChoice.weightIter().sizeHint`;
- `WeightedChoice.probabilityIter().sizeHint`;
- `Charset.ProbabilityIterator.sizeHint`.

Semantics:

- returns an exact lower/upper pair for remaining items;
- `.lower == remaining()`;
- `.upper == remaining()`;
- decreases after `next()` and `fill()`;
- reaches `0..0` after exhaustion;
- preserves existing `next`, `remaining`, `len`, and `fill` behavior.

Focused tests verify before/after `next()` and after `fill()` for `AliasTable`
weight/probability iterators, `WeightedChoice` weight/probability iterators,
`Choice` probability iterators, and `Charset` probability iterators.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints size-hint rows for `AliasTable`
  weight/probability iterators and `WeightedChoice` weight/probability
  iterators.
- `examples/sequence_sampling.zig` prints a `Choice.probabilityIter sizeHint`
  row.
- `examples/string_generation.zig` prints a
  `custom charset probabilityIter sizeHint` row.
- `tools/examplecheck.zig` verifies those example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the size-hint diagnostics.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M202.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "alias table exposes totals"`
- `zig test src/root.zig --test-filter "choice sampler"`
- `zig test src/root.zig --test-filter "weighted choice sampler"`
- `zig test src/root.zig --test-filter "ascii"`
- `zig build run-weighted-sampling`
- `zig build run-sequence-sampling`
- `zig build run-string-generation`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked diagnostic-iterator ergonomics gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
