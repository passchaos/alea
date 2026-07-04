# S4-M78 F64 Weighted U32 Index Choice

Date: 2026-07-04

Purpose: add a compact f64-weighted one-shot index helper in the `Rng` facade.
This complements `Rng.weightedIndex`, S4-M77 generic `seq.weightedIndexU32`, and
the weighted `u32` no-replacement APIs from S4-M70 through S4-M72.

## Change

Added compact f64 weighted index helpers in `src/rng.zig`:

- `Rng.weightedIndexU32(weights)`;
- `Rng.weightedIndexU32From(source, weights)`;
- `Rng.weightedIndexU32Checked(weights)`;
- `Rng.weightedIndexU32CheckedFrom(source, weights)`.

The helpers return `?u32`, preserve the existing f64 weighted-index validation
rules, and reject weight slices longer than `maxInt(u32)` before narrowing.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints a `one-shot weighted u32 index` row;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions f64 usize/u32 weighted indexes;
- `tools/examplecheck.zig` guards the weighted example token;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M78 evidence.

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

- optional and checked f64 weighted `u32` index choice;
- direct-source/facade stream-shape parity;
- single-positive no-consume behavior;
- invalid-weight no-consume errors.

## S4-M78 Decision

S4-M78 is closed for the current compact f64 weighted-index bar: callers using
the `Rng` facade can now select a single weighted `u32` index without widening
through `usize`.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
