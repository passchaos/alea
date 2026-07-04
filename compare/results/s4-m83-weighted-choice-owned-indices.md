# S4-M83 WeightedChoice Owned Index Batches

Date: 2026-07-04

Purpose: add allocation-returning index batches for reusable weighted
`WeightedChoice`. This complements S4-M79 caller-owned weighted-choice index
fills, S4-M81 single weighted-choice index samples, and S4-M82 unweighted
`Choice` owned index batches.

## Change

Added reusable weighted-choice owned-index helpers in `src/seq.zig`:

- `WeightedChoice.indices(allocator, rng, amount)`;
- `WeightedChoice.indicesFrom(allocator, source, amount)`;
- `WeightedChoice.indicesU32(allocator, rng, amount)`;
- `WeightedChoice.indicesU32From(allocator, source, amount)`.

`indicesU32*` rejects item slices longer than `maxInt(u32)` before allocating or
narrowing. Single-positive weighted choices fill the deterministic positive
index without consuming randomness.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints `WeightedChoice.indicesFrom` and
  `WeightedChoice.indicesU32From` rows;
- `docs/examples.md` describes weighted-choice owned index batches;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions weighted choice owned index batches;
- `tools/examplecheck.zig` guards the weighted example token;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M83 evidence.

## Validation

Commands for final validation:

```sh
git diff --check
zig build test
zig build run-weighted-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- allocation-returning `usize` and `u32` weighted-choice index batches;
- allocation-failure paths without stream consumption;
- single-positive no-consume behavior;
- index outputs stay within non-zero weighted item bounds.

## S4-M83 Decision

S4-M83 is closed for the current reusable weighted-choice owned-index batch bar:
callers can now request owned repeated weighted-choice indexes without supplying
a buffer and without mapping through values or pointers.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
