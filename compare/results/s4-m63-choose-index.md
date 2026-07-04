# S4-M63 One-Shot Index Choice

Date: 2026-07-04

Purpose: add explicit one-shot unweighted index choice helpers. This complements
value-returning `Rng.choose`, const/mutable pointer choice APIs, and larger index
subset samplers such as `sampleIndices` / `sampleIndexVec` without requiring
callers to spell a raw integer-range helper.

## Change

Added one-shot index choice helpers in `src/rng.zig`:

- `Rng.chooseIndex(length)`;
- `Rng.chooseIndexFrom(source, length)`;
- `Rng.chooseIndexChecked(length)`;
- `Rng.chooseIndexCheckedFrom(source, length)`.

The optional forms return `null` for `length == 0`; checked forms return
`error.EmptyRange` before drawing. `length == 1` returns index `0` without
consuming randomness, matching the point-mass behavior of item and pointer choice
helpers.

Updated adoption/docs:

- `examples/basic.zig` prints an index choice from an immutable slice;
- `docs/examples.md` mentions index and const-pointer choice in the basic example;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions one-shot index choice;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M63 evidence.

## Validation

Commands:

```sh
git diff --check
zig build test
zig build run-basic
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- optional and checked index choice;
- empty optional and checked no-consume behavior;
- singleton no-consume behavior;
- facade/direct stream-shape parity.

## S4-M63 Decision

S4-M63 is closed for the current one-shot index-choice bar: callers can now
sample a single index from `0..length` through an explicit collection helper.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
