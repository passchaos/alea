# S4-M172 Choice Index Iterators

Result: passed.

Purpose: add repeated `usize` and compact `u32` index iterators for reusable
`Choice` and `WeightedChoice`. Before this milestone, reusable choices already
had one-shot index samples, caller-owned index fills, allocation-returning index
batches, and fixed-size index arrays. Static `AliasTable` and dynamic weighted
trees also exposed repeated index iterators. S4-M172 closes the reusable
`Choice` / `WeightedChoice` iterator ergonomics gap without changing existing
value/pointer iterator behavior.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/slice.rs` exposes repeated slice selection
  through `choose` / user loops and iterator-style collection;
- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs` exposes
  reusable weighted-index sampling;
- Alea already had `AliasTable.iter*` and `WeightedTree.iter*` repeated index
  streams, plus reusable `Choice` / `WeightedChoice` index fills and fixed
  arrays.

This milestone keeps a Zig-native API: reusable choice index streams are named
`indexIter*`, while existing `iter*` keeps returning repeated item pointers.

## Alea API Added

`src/seq.zig` now exposes these `Choice(T)` members:

- `Choice.indexIter`;
- `Choice.indexIterFrom`;
- `Choice.indexIterU32`;
- `Choice.indexIterU32From`;
- `Choice.IndexIterator`;
- `Choice.IndexIterator.next`;
- `Choice.IndexIterator.nextValue`;
- `Choice.IndexIterator.fill`;
- `Choice.U32IndexIterator`;
- `Choice.U32IndexIterator.next`;
- `Choice.U32IndexIterator.nextValue`;
- `Choice.U32IndexIterator.fill`.

It also exposes matching `WeightedChoice(T, Weight)` members:

- `WeightedChoice.indexIter`;
- `WeightedChoice.indexIterFrom`;
- `WeightedChoice.indexIterU32`;
- `WeightedChoice.indexIterU32From`;
- `WeightedChoice.IndexIterator`;
- `WeightedChoice.IndexIterator.next`;
- `WeightedChoice.IndexIterator.nextValue`;
- `WeightedChoice.IndexIterator.fill`;
- `WeightedChoice.U32IndexIterator`;
- `WeightedChoice.U32IndexIterator.next`;
- `WeightedChoice.U32IndexIterator.nextValue`;
- `WeightedChoice.U32IndexIterator.fill`.

Focused tests verify:

- facade and direct-source iterators preserve canonical sample/fill stream shape;
- `next`, `nextValue`, and `fill` produce valid indexes;
- compact `u32` iterators mirror `fillIndicesU32From`;
- singleton `Choice` and single-positive `WeightedChoice` iterators do not
  consume random streams.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `Choice.indexIterFrom fill` and
  `Choice.indexIterU32From fill` rows.
- `examples/weighted_sampling.zig` prints `WeightedChoice.indexIterFrom fill`
  and `WeightedChoice.indexIterU32From fill` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the parity matrix, and the
  active-goal audit describe the repeated reusable choice index stream
  semantics.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "Choice index iterators"`
- `zig test src/root.zig --test-filter "WeightedChoice index iterators"`
- `zig build run-sequence-sampling`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked reusable choice index-stream ergonomics gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
