# S4-M38 Fixed-Size Weighted Index Array Sampling

Date: 2026-07-04

Purpose: complement S4-M37's fixed-size weighted item arrays with direct
fixed-size weighted index arrays, giving callers allocation-free access to the
selected indexes before mapping them to domain-specific data structures.

## Change

Added fixed-size weighted index helpers in `src/seq.zig`:

- `sampleWeightedIndexArray(rng, Weight, N, weights) Error!?[N]usize`
- `sampleWeightedIndexArrayFrom(source, Weight, N, weights) Error!?[N]usize`
- `sampleWeightedIndexArrayChecked(rng, Weight, N, weights) Error![N]usize`
- `sampleWeightedIndexArrayCheckedFrom(source, Weight, N, weights) Error![N]usize`

The optional forms return `null` when there are not enough positive-weight
entries. The checked forms return `error.InvalidParameter` before drawing in that
case. Invalid weights are rejected before drawing, and single-positive `N == 1`
inputs return the only possible index without consuming randomness. The item
array helpers now use the same fixed-size index-array core.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints a fixed-size weighted index array;
- `docs/examples.md` describes fixed-size weighted item and index arrays;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions fixed-size weighted item/index arrays;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` record the weighted sequence
  ergonomics comparison.

## Validation

Commands:

```sh
zig build test
zig build run-weighted-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- optional, checked, facade, and direct-source forms;
- single-positive no-consume behavior;
- not-enough-positive optional `null` and checked `InvalidParameter` behavior;
- invalid-weight no-consume behavior;
- facade/direct stream-shape parity.

## S4-M38 Decision

S4-M38 is closed for the current fixed-size weighted index array bar: users can
obtain allocation-free weighted index arrays directly or use fixed-size weighted
item arrays for mapped values.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
