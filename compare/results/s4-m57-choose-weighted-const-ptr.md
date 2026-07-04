# S4-M57 Weighted Const-Pointer Single Choice

Date: 2026-07-04

Purpose: add explicit one-shot weighted const-pointer choice helpers for
immutable item slices. This complements value-returning `chooseWeighted`, mutable
`chooseWeightedPtr`, S4-M56 unweighted const-pointer choice, and the recent
weighted pointer subset APIs without requiring mutable slice input.

## Change

Added weighted const-pointer choice helpers in `src/seq.zig`:

- `seq.chooseWeightedConstPtr(rng, T, Weight, items, weights)`;
- `seq.chooseWeightedConstPtrFrom(source, T, Weight, items, weights)`;
- `seq.chooseWeightedConstPtrChecked(rng, T, Weight, items, weights)`;
- `seq.chooseWeightedConstPtrCheckedFrom(source, T, Weight, items, weights)`.

The optional forms return `null` when no positive weight is available; checked
forms return `error.EmptyInput` before exposing a result. Single-positive inputs
return the positive item pointer without consuming randomness, matching
`chooseWeighted` and `chooseWeightedPtr` point-mass behavior.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints a one-shot weighted const-pointer
  choice from an immutable slice;
- `docs/examples.md` mentions one-shot weighted const pointers;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions one-shot weighted item/const-pointer/mutable-pointer helpers;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M57 evidence.

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

- optional and checked weighted const-pointer choice;
- no-positive optional and checked behavior;
- single-positive no-consume behavior;
- facade/direct stream-shape parity;
- length-mismatch and invalid-weight paths that do not consume RNG state.

## S4-M57 Decision

S4-M57 is closed for the current weighted const-pointer single-choice bar:
one-shot weighted choice can now return `*const T` from immutable item slices
without copying values and without requiring mutable slice input.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
