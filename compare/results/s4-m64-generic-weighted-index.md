# S4-M64 Generic One-Shot Weighted Index

Date: 2026-07-04

Purpose: add generic-weight one-shot weighted index helpers. This complements the
existing `Rng.weightedIndex` f64 helper, generic weighted value/pointer choice,
and weighted no-replacement APIs so callers can select one index from integer or
float weight slices without converting to f64 manually.

## Change

Added generic one-shot weighted index helpers in `src/seq.zig`:

- `seq.weightedIndex(rng, Weight, weights)`;
- `seq.weightedIndexFrom(source, Weight, weights)`;
- `seq.weightedIndexChecked(rng, Weight, weights)`;
- `seq.weightedIndexCheckedFrom(source, Weight, weights)`.

The helpers reuse the generic weighted-index core used by `chooseWeighted`, so
integer and float weights share the same validation semantics. Empty or all-zero
weights return `null`; invalid negative, infinite, NaN, or overflowing totals
return `error.InvalidWeight`. Single-positive inputs return the positive index
without consuming randomness.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints a generic `u32` one-shot weighted index;
- `docs/examples.md` describes f64/generic weighted indexes;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions f64/generic weighted indexes;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M64 evidence.

## Validation

Commands:

```sh
git diff --check
zig build test
zig build run-weighted-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- optional and checked generic weighted index choice;
- empty/all-zero optional and checked behavior;
- single-positive no-consume behavior;
- facade/direct stream-shape parity;
- invalid-weight paths that do not consume RNG state.

## S4-M64 Decision

S4-M64 is closed for the current generic weighted-index bar: callers can now
sample one weighted index from integer or float weight slices through the
sequence namespace without manual weight conversion.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
