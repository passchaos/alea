# S4-M77 Generic Weighted U32 Index Choice

Date: 2026-07-04

Purpose: add a compact one-shot weighted index helper for generic integer or
float weight slices. This complements S4-M64 generic `weightedIndex`,
`Rng.weightedIndex`, S4-M76 one-shot unweighted `u32` index choice, and the
weighted `u32` no-replacement APIs from S4-M70 through S4-M72.

## Change

Added compact generic weighted index helpers in `src/seq.zig`:

- `seq.weightedIndexU32(rng, Weight, weights)`;
- `seq.weightedIndexU32From(source, Weight, weights)`;
- `seq.weightedIndexU32Checked(rng, Weight, weights)`;
- `seq.weightedIndexU32CheckedFrom(source, Weight, weights)`.

The helpers return `?u32` and accept the same generic integer/float weight
families as `seq.weightedIndex`. They reject weight slices longer than
`maxInt(u32)` before narrowing.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints a `generic weighted u32 index` row;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions generic usize/u32 weighted indexes;
- `tools/examplecheck.zig` guards the weighted example token;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M77 evidence.

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

- optional and checked generic weighted `u32` index choice;
- direct-source/facade stream-shape parity;
- single-positive no-consume behavior;
- empty/all-zero optional results;
- invalid-weight no-consume errors.

## S4-M77 Decision

S4-M77 is closed for the current compact generic weighted-index bar: callers can
now select a single weighted `u32` index from generic numeric weights without
widening through `usize`.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
