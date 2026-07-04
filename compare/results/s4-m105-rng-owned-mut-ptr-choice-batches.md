# S4-M105 Rng Repeated Mutable-Pointer Choice Batches

Date: 2026-07-04

Purpose: add caller-owned and allocation-returning repeated mutable-pointer
choice helpers for `Rng`. This complements one-shot `choosePtr`, S4-M104
repeated const-pointer choice batches, reusable pointer samplers, and no-copy
mutable workflows.

## Rust rand Comparison

Rust slice choice APIs can repeatedly choose mutable references through iterator
loops when callers need in-place mutation. Alea already had one-shot
`choosePtr`, repeated value batches, repeated const-pointer batches, and reusable
pointer samplers; S4-M105 adds direct Zig-native caller-owned and owned repeated
mutable-pointer choice batches for the simple with-replacement mutable no-copy
case.

## Change

Added repeated mutable-pointer choice helpers in `src/rng.zig`:

- `Rng.fillChoosePtr(T, dest, items)`;
- `Rng.fillChoosePtrFrom(source, T, dest, items)`;
- `Rng.fillChoosePtrChecked(T, dest, items)`;
- `Rng.fillChoosePtrCheckedFrom(source, T, dest, items)`;
- `Rng.choosePtrBatch(T, allocator, count, items)`;
- `Rng.choosePtrBatchFrom(source, T, allocator, count, items)`;
- `Rng.choosePtrBatchChecked(T, allocator, count, items)`;
- `Rng.choosePtrBatchCheckedFrom(source, T, allocator, count, items)`.

The checked helpers return zero-count slices before validating empty inputs,
return empty-input errors before allocating/drawing for positive counts, allocate
before consuming randomness, and fill singleton choices with the only pointer
without consuming randomness.

Updated adoption/docs:

- `examples/basic.zig` prints a `mutable pointer choice batch` row;
- `tools/examplecheck.zig` guards the basic example token;
- `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, and
  `README.md` list the new APIs;
- `compare/results/linux-no-known-gaps-audit.md` includes S4-M105 evidence.

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

- facade/direct stream-shape parity for caller-owned mutable-pointer fills and
  owned batches;
- singleton no-consume behavior for fills and owned batches;
- zero-length checked fills returning before empty-input validation;
- invalid positive-count empty choices returning before allocation or stream
  consumption;
- allocation-failure paths without stream consumption.

## S4-M105 Decision

S4-M105 is closed for the current repeated mutable-pointer choice batch bar:
callers can now fill caller-owned mutable-pointer buffers or request owned
mutable-pointer slices for with-replacement repeated mutable choices without
copying item values.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
