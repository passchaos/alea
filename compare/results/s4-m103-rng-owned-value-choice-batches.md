# S4-M103 Rng Repeated Value Choice Batches

Date: 2026-07-04

Purpose: add caller-owned and allocation-returning repeated value-choice helpers
for `Rng`. This complements one-shot `choose`, S4-M102 repeated index choice
batches, reusable `Choice.values*`, and no-replacement sequence samplers.

## Rust rand Comparison

Rust `rand` supports repeated with-replacement value choices through iterator
loops and slice choice APIs. Alea already had one-shot `choose`, reusable
`Choice.values*`, and no-replacement value subset helpers; S4-M103 adds direct
Zig-native caller-owned and owned repeated value-choice batches for the simple
with-replacement case.

## Change

Added repeated value choice helpers in `src/rng.zig`:

- `Rng.fillChoose(T, dest, items)`;
- `Rng.fillChooseFrom(source, T, dest, items)`;
- `Rng.fillChooseChecked(T, dest, items)`;
- `Rng.fillChooseCheckedFrom(source, T, dest, items)`;
- `Rng.chooseBatch(T, allocator, count, items)`;
- `Rng.chooseBatchFrom(source, T, allocator, count, items)`;
- `Rng.chooseBatchChecked(T, allocator, count, items)`;
- `Rng.chooseBatchCheckedFrom(source, T, allocator, count, items)`.

The checked helpers return zero-count slices before validating empty inputs,
return empty-input errors before allocating/drawing for positive counts, allocate
before consuming randomness, and fill singleton choices with the only value
without consuming randomness.

Updated adoption/docs:

- `examples/basic.zig` prints a `value choice batch` row;
- `tools/examplecheck.zig` guards the basic example token;
- `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, and
  `README.md` list the new APIs;
- `compare/results/linux-no-known-gaps-audit.md` includes S4-M103 evidence.

## Validation

Commands for final validation:

```sh
git diff --check
zig build test
zig build run-basic
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- facade/direct stream-shape parity for caller-owned fills and owned batches;
- singleton no-consume behavior for fills and owned batches;
- zero-length checked fills and zero-count checked batches returning before
  empty-input validation;
- invalid positive-count empty choices returning before allocation or stream
  consumption;
- allocation-failure paths without stream consumption.

## S4-M103 Decision

S4-M103 is closed for the current repeated value choice batch bar: callers can
now fill caller-owned value buffers or request owned value slices for
with-replacement repeated choices.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
