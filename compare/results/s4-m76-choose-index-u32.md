# S4-M76 One-Shot U32 Index Choice

Date: 2026-07-04

Purpose: add a compact one-shot index choice helper for callers whose population
length fits `u32`. This complements `Rng.chooseIndex`, allocation-returning
`sampleIndicesU32`, caller-owned `sampleIndicesU32Into`, and fixed-size
`sampleArrayU32`.

## Change

Added one-shot compact index helpers in `src/rng.zig`:

- `Rng.chooseIndexU32(length)`;
- `Rng.chooseIndexU32From(source, length)`;
- `Rng.chooseIndexU32Checked(length)`;
- `Rng.chooseIndexU32CheckedFrom(source, length)`.

The optional forms return `null` for empty ranges. Checked forms return
`error.EmptyRange` before drawing for empty ranges. Singleton ranges return `0`
without drawing.

Updated adoption/docs:

- `examples/basic.zig` prints a `u32 index choice` row;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions one-shot usize/u32 index choice and uses
  `rng.chooseIndexU32` in the quick start;
- `tools/examplecheck.zig` guards the basic example token;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M76 evidence.

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

- optional and checked one-shot `u32` index choice;
- direct-source/facade stream-shape parity;
- singleton no-consume behavior;
- empty checked/optional no-consume behavior.

## S4-M76 Decision

S4-M76 is closed for the current compact one-shot index-choice bar: callers can
now select a single compact `u32` index without spelling a raw bounded `u32`
integer draw or widening through `usize`.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
