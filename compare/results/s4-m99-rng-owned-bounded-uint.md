# S4-M99 Rng Owned Bounded Uint Batches

Date: 2026-07-04

Purpose: add caller-owned and allocation-returning bounded unsigned integer
helpers for `Rng`. This complements `uintLessThan`, `uintAtMost`, S4-M85 owned
value batches, and S4-M87 offset range batches with direct zero-based bounded
unsigned workflows.

## Rust rand Comparison

Rust `rand` exposes `random_range`/`random_range(..=)` and repeated sampling via
iterators or user loops. Alea already had one-shot `uintLessThan` /
`uintAtMost` and general `rangeBatch`; S4-M99 adds direct Zig-native fill and
owned batch helpers for the common zero-based bounded unsigned case without
forcing callers to spell `rangeBatch(T, 0, bound)` or loop manually.

## Change

Added bounded unsigned helpers in `src/rng.zig`:

- `Rng.fillUintLessThan(T, dest, less_than)`;
- `Rng.fillUintLessThanFrom(source, T, dest, less_than)`;
- `Rng.fillUintLessThanChecked(T, dest, less_than)`;
- `Rng.fillUintLessThanCheckedFrom(source, T, dest, less_than)`;
- `Rng.uintLessThanBatch(T, allocator, count, less_than)`;
- `Rng.uintLessThanBatchFrom(source, T, allocator, count, less_than)`;
- `Rng.uintLessThanBatchChecked(T, allocator, count, less_than)`;
- `Rng.uintLessThanBatchCheckedFrom(source, T, allocator, count, less_than)`;
- `Rng.fillUintAtMost(T, dest, at_most)`;
- `Rng.fillUintAtMostFrom(source, T, dest, at_most)`;
- `Rng.uintAtMostBatch(T, allocator, count, at_most)`;
- `Rng.uintAtMostBatchFrom(source, T, allocator, count, at_most)`.

The new `uintLessThan` checked helpers validate `less_than != 0` before drawing
or allocating for positive counts. Degenerate `less_than == 1` and `at_most == 0`
paths fill/allocate zeros without consuming randomness. Allocation failures
happen before stream consumption.

Updated adoption/docs:

- `examples/basic.zig` prints `uintLessThanBatch u16 <1000` and
  `uintAtMostBatch u16 <=999` rows;
- `tools/examplecheck.zig` guards the example tokens;
- `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, and
  `README.md` list the new APIs;
- `compare/results/linux-no-known-gaps-audit.md` includes S4-M99 evidence.

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

- checked/unchecked `fillUintLessThan` stream-shape parity;
- checked/unchecked `uintLessThanBatch` stream-shape parity;
- `fillUintAtMost` and `uintAtMostBatch` parity with `less_than = at_most + 1`;
- zero-count checked batches returning before invalid validation/allocation;
- invalid positive-count `less_than == 0` returning before allocation or stream
  consumption;
- allocation-failure paths without stream consumption;
- degenerate `less_than == 1` / `at_most == 0` no-consume behavior.

## S4-M99 Decision

S4-M99 is closed for the current bounded unsigned fill/owned batch bar: callers
can now fill caller-owned unsigned integer buffers or request owned zero-based
bounded unsigned slices directly.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
