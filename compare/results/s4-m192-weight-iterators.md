# S4-M192 Weighted Sampler Weight Iterators

Result: passed.

Purpose: add lazy weight iterators to static weighted samplers. Local Rust
`WeightedIndex::weights()` returns an iterator over reconstructed weights, built
on `WeightedIndex::weight(index)`. Alea already exposed allocation-returning and
caller-buffer weight exports plus S4-M191 optional single-weight lookup; S4-M192
adds a lazy iterator form for users who want one-pass diagnostics without an
allocation.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs` defines
  `WeightedIndexIter`;
- `WeightedIndexIter.next` calls `weighted_index.weight(index)` and stops at
  `None`;
- `WeightedIndex::weights()` returns `WeightedIndexIter`.

Alea keeps explicit Zig methods and exposes reconstructed alias-table weights as
`f64`, matching the existing `weights` / `weightsInto` diagnostic surface.

## Alea API Added

`src/distributions.zig` now exposes:

- `AliasTable.WeightIterator`;
- `AliasTable.weightIter`;
- `AliasTable.WeightIterator.next`;
- `AliasTable.WeightIterator.remaining`;
- `AliasTable.WeightIterator.len`;
- `AliasTable.WeightIterator.fill`.

`src/seq.zig` now exposes:

- `WeightedChoice.weightIter`.

Semantics:

- streams reconstructed weights in index order;
- `next()` returns `null` after the final weight;
- `remaining()` and `len()` report exact remaining counts;
- `fill()` drains up to the destination length and returns the filled count;
- preserves existing allocation-returning `weights` and caller-buffer
  `weightsInto` APIs.

Focused tests verify `next`, exact remaining counts, `len`, caller-buffer fill,
and exhaustion for `AliasTable` and `WeightedChoice`.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `alias weightIter fill` and
  `WeightedChoice.weightIter fill` rows.
- `tools/examplecheck.zig` verifies those example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe lazy weight iterators.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M193.

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

This milestone closes an unblocked weighted-sampler introspection ergonomics gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
