# S4-M104 Rng Repeated Const-Pointer Choice Batches

Date: 2026-07-04

Purpose: add caller-owned and allocation-returning repeated const-pointer choice
helpers for `Rng`. This complements one-shot `chooseConstPtr`, S4-M103 repeated
value choice batches, reusable `Choice.ptrs*`, and no-copy workflows for large
immutable items.

## Rust rand Comparison

Rust slice choice APIs can repeatedly choose references through iterator loops.
Alea already had one-shot `chooseConstPtr`, repeated value batches, and reusable
`Choice.ptrs*`; S4-M104 adds direct Zig-native caller-owned and owned repeated
const-pointer choice batches for the simple with-replacement no-copy case.

## Change

Added repeated const-pointer choice helpers in `src/rng.zig`:

- `Rng.fillChooseConstPtr(T, dest, items)`;
- `Rng.fillChooseConstPtrFrom(source, T, dest, items)`;
- `Rng.fillChooseConstPtrChecked(T, dest, items)`;
- `Rng.fillChooseConstPtrCheckedFrom(source, T, dest, items)`;
- `Rng.chooseConstPtrBatch(T, allocator, count, items)`;
- `Rng.chooseConstPtrBatchFrom(source, T, allocator, count, items)`;
- `Rng.chooseConstPtrBatchChecked(T, allocator, count, items)`;
- `Rng.chooseConstPtrBatchCheckedFrom(source, T, allocator, count, items)`.

The checked helpers return zero-count slices before validating empty inputs,
return empty-input errors before allocating/drawing for positive counts, allocate
before consuming randomness, and fill singleton choices with the only pointer
without consuming randomness.

Updated adoption/docs:

- `examples/basic.zig` prints a `const pointer choice batch` row;
- `tools/examplecheck.zig` guards the basic example token;
- `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, and
  `README.md` list the new APIs;
- `compare/results/linux-no-known-gaps-audit.md` includes S4-M104 evidence.

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

- facade/direct stream-shape parity for caller-owned const-pointer fills and
  owned batches;
- singleton no-consume behavior for fills and owned batches;
- zero-length checked fills and zero-count checked batches returning before
  empty-input validation;
- invalid positive-count empty choices returning before allocation or stream
  consumption;
- allocation-failure paths without stream consumption.

## S4-M104 Decision

S4-M104 is closed for the current repeated const-pointer choice batch bar:
callers can now fill caller-owned pointer buffers or request owned pointer slices
for with-replacement repeated immutable choices without copying item values.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
