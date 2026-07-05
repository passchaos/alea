# S4-M177 IndexVec Consuming Iterator

Result: passed.

Purpose: add a consuming iterator for owned `IndexVec` results. Local Rust
`rand` implements `IntoIterator for IndexVec` and exposes `IndexVecIntoIter`,
letting callers consume an index vector into a stream of `usize` indexes. Alea
already had borrowed `IndexVec.iter`; this milestone adds Zig-native consuming
iteration with explicit allocator cleanup.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/index.rs` implements `IntoIterator for
  IndexVec`;
- the returned `IndexVecIntoIter` owns the backing vector and yields `usize`
  indexes;
- `IndexVecIntoIter` exposes `next` and exact-size `size_hint` semantics.

Alea uses explicit allocator ownership instead of Rust's implicit `Vec` drop.
The new consuming iterator stores the consumed `IndexVec` plus the allocator
needed to release it, exposes `next` and `remaining`, and requires `deinit`.

## Alea API Added

`src/seq.zig` now exposes:

- `IndexVec.intoIter(allocator)`;
- `IndexVec.IntoIterator`;
- `IndexVec.IntoIterator.next`;
- `IndexVec.IntoIterator.remaining`;
- `IndexVec.IntoIterator.deinit`.

Semantics:

- consumes compact `u32` or native `usize` owned backings;
- yields indexes as `usize` values;
- tracks exact remaining count;
- releases the consumed backing through `IntoIterator.deinit` and the allocator
  supplied to `intoIter`.

Focused tests verify compact and native backings, yielded values, exact
remaining counts, end-of-iteration behavior, and owned cleanup via the test
allocator.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints an `IndexVec.intoIter` row.
- `tools/examplecheck.zig` verifies the example source token.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe consuming `IndexVec` index iteration.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "consuming iterator"`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked `IndexVec` consuming-iteration ergonomics gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
