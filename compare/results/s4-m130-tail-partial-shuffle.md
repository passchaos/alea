# S4-M130 Rust-Style Tail Partial Shuffle

Result: passed.

Purpose: add a tail-selected partial shuffle shape matching local Rust
`SliceRandom::partial_shuffle`. Alea already had head-selected
`partialShuffle*` helpers; this milestone preserves that Zig-native API and
adds explicit `partialShuffleTail*` helpers for Rust selected-tail/rest-prefix
semantics.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs`:

- `SliceRandom::partial_shuffle(rng, amount)` shuffles selected elements into
  the tail of the slice;
- it returns `(selected_tail, rest_prefix)`;
- if `amount >= len`, it behaves like a full shuffle;
- `SliceRandom::shuffle` is implemented in terms of full partial shuffle.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.partialShuffleTail`;
- `seq.partialShuffleTailFrom`;
- `seq.partialShuffleTailChecked`;
- `seq.partialShuffleTailCheckedFrom`;
- `seq.PartialShuffleTailSplit(T)`;
- `seq.partialShuffleTailSplit`;
- `seq.partialShuffleTailSplitFrom`;
- `seq.partialShuffleTailSplitChecked`;
- `seq.partialShuffleTailSplitCheckedFrom`.

The new helpers select into `items[items.len - count ..]` and return the tail as
the selected slice. Split forms return `{ .selected = tail, .rest = prefix }`.
Checked forms reject `amount > items.len` before drawing.

Focused tests cover:

- tail slice location and split selected/rest views;
- checked and unchecked forms;
- zero-count no-consume behavior;
- invalid-count no-consume behavior.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `partialShuffleTailSplit`.
- `tools/examplecheck.zig` verifies that example token.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe head-selected and Rust-style tail-selected partial shuffle variants.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "partial shuffle"`
- `zig build test`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked sequence API semantics gap only. It does not
resolve S4-M11's exact/default-compatible dense SIMD normal/exponential blocker,
does not add a new architecture/runtime runner, and is not whole-goal completion
evidence.
