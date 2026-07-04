# S4-M82 Choice Owned Index Batches

Date: 2026-07-04

Purpose: add allocation-returning index batches for reusable unweighted `Choice`.
This complements S4-M80 caller-owned index fills and S4-M81 single index samples.

## Change

Added reusable choice owned-index helpers in `src/seq.zig`:

- `Choice.indices(allocator, rng, amount)`;
- `Choice.indicesFrom(allocator, source, amount)`;
- `Choice.indicesU32(allocator, rng, amount)`;
- `Choice.indicesU32From(allocator, source, amount)`.

`indicesU32*` rejects item slices longer than `maxInt(u32)` before narrowing.
Single-item choices fill deterministic index `0` without consuming randomness.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints `Choice.indicesFrom` and
  `Choice.indicesU32From` rows;
- `docs/examples.md` describes reusable choice owned index batches;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions repeated choice owned index batches;
- `tools/examplecheck.zig` guards the sequence example token;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M82 evidence.

## Validation

Commands for final validation:

```sh
git diff --check
zig build test
zig build run-sequence-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- allocation-returning `usize` and `u32` choice index batches;
- allocation-failure paths;
- single-item no-consume behavior;
- index outputs stay within item bounds.

## S4-M82 Decision

S4-M82 is closed for the current reusable choice owned-index batch bar: callers
can now request owned repeated choice indexes without supplying a buffer and
without mapping through values or pointers.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
