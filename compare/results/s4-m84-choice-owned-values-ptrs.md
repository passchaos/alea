# S4-M84 Choice Owned Values and Pointers

Date: 2026-07-04

Purpose: add allocation-returning value and const-pointer batches for reusable
`Choice` and `WeightedChoice` samplers. This complements their existing
caller-owned value/pointer fills plus the S4-M82/S4-M83 owned index batches.

## Change

Added reusable unweighted choice owned value/pointer helpers in `src/seq.zig`:

- `Choice.values(allocator, rng, amount)`;
- `Choice.valuesFrom(allocator, source, amount)`;
- `Choice.ptrs(allocator, rng, amount)`;
- `Choice.ptrsFrom(allocator, source, amount)`.

Added reusable weighted choice owned value/pointer helpers in `src/seq.zig`:

- `WeightedChoice.values(allocator, rng, amount)`;
- `WeightedChoice.valuesFrom(allocator, source, amount)`;
- `WeightedChoice.ptrs(allocator, rng, amount)`;
- `WeightedChoice.ptrsFrom(allocator, source, amount)`.

Single-item `Choice` and single-positive `WeightedChoice` owned batches fill the
deterministic value or pointer without consuming randomness after allocation.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints `Choice.valuesFrom` and
  `Choice.ptrsFrom` rows;
- `examples/weighted_sampling.zig` prints `WeightedChoice.valuesFrom` and
  `WeightedChoice.ptrsFrom` rows;
- `docs/examples.md` describes reusable choice owned value/pointer/index batches;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions repeated choice owned value/pointer/index batches;
- `tools/examplecheck.zig` guards the sequence and weighted example tokens;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M84 evidence.

## Validation

Commands for final validation:

```sh
git diff --check
zig build test
zig build run-sequence-sampling
zig build run-weighted-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- allocation-returning value and const-pointer batches for `Choice`;
- allocation-returning value and const-pointer batches for `WeightedChoice`;
- allocation-failure paths without stream consumption;
- single-item and single-positive no-consume behavior;
- sampled values and pointers stay within the input item set and avoid
  zero-weight weighted entries.

## S4-M84 Decision

S4-M84 is closed for the current reusable choice owned value/pointer batch bar:
callers can now request owned repeated values or const pointers without supplying
a buffer, for both unweighted and weighted reusable choice samplers.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
