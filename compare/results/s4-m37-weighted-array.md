# S4-M37 Fixed-Size Weighted Array Sampling

Date: 2026-07-04

Purpose: extend the recent sequence ergonomics work to weighted no-replacement
sampling. Alea already had allocation-returning weighted item samples and
one-shot weighted item/pointer choice; this milestone adds fixed-size weighted
item arrays without heap allocation.

## Change

Added fixed-size weighted item helpers in `src/seq.zig`:

- `sampleWeightedArray(rng, T, Weight, N, items, weights) !?[N]T`
- `sampleWeightedArrayFrom(source, T, Weight, N, items, weights) !?[N]T`
- `sampleWeightedArrayChecked(rng, T, Weight, N, items, weights) ![N]T`
- `sampleWeightedArrayCheckedFrom(source, T, Weight, N, items, weights) ![N]T`

The optional forms return `null` when there are not enough positive-weight
entries. The checked forms return `error.InvalidParameter` before drawing in that
case. Length mismatches and invalid weights are rejected before drawing.
Single-positive `N == 1` inputs return the only possible item without consuming
randomness. The implementation uses a fixed `[N]WeightedCandidate` buffer and
keeps the selected top keys in-place, avoiding heap allocation for fixed-size
weighted samples.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints a fixed-size weighted array sample;
- `docs/examples.md` describes fixed-size weighted array workflows;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions fixed-size weighted arrays;
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
- length-mismatch and invalid-weight no-consume behavior;
- facade/direct stream-shape parity.

## S4-M37 Decision

S4-M37 is closed for the current fixed-size weighted array bar: users can choose
between weighted indexes, one-shot weighted values/pointers, fixed-size weighted
arrays, allocation-returning weighted no-replacement samples, reusable weighted
choices, and weighted iterators.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
