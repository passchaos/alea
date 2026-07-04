# S4-M39 Fixed-Size Weighted Iterator Array Sampling

Date: 2026-07-04

Purpose: extend fixed-size weighted sampling to streaming weighted iterators.
Alea already had allocation-returning weighted iterator sampling and fixed-size
weighted slice arrays; this milestone adds allocation-free `[N]T` samples for
iterator entries shaped as `{ .item, .weight }`.

## Change

Added fixed-size weighted iterator helpers in `src/seq.zig`:

- `sampleIteratorWeightedArray(rng, T, N, iterator) !?[N]T`
- `sampleIteratorWeightedArrayFrom(source, T, N, iterator) !?[N]T`
- `sampleIteratorWeightedArrayChecked(rng, T, N, iterator) ![N]T`
- `sampleIteratorWeightedArrayCheckedFrom(source, T, N, iterator) ![N]T`

The optional forms return `null` when the iterator does not provide enough
positive-weight entries. The checked forms return `error.InvalidParameter` in
that case. Invalid weights are rejected, zero-length requests do not read the
iterator or consume randomness, and single-positive `N == 1` inputs return the
only possible item without consuming randomness. The implementation keeps a fixed
`[N]WeightedIteratorCandidate(T)` buffer and replaces the current minimum key in
place, avoiding heap allocation for fixed-size weighted iterator samples.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints a fixed-size weighted iterator array;
- `docs/examples.md` describes fixed-size weighted iterator arrays;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions fixed-size weighted iterator arrays.

## Validation

Commands:

```sh
zig build test
zig build run-sequence-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- optional, checked, facade, and direct-source forms;
- zero-length no-read/no-consume behavior;
- single-positive no-consume behavior;
- optional short-stream `null` and checked short-stream `InvalidParameter`;
- invalid-weight no-consume behavior for validation-before-draw cases;
- facade/direct stream-shape parity.

## S4-M39 Decision

S4-M39 is closed for the current fixed-size weighted iterator array bar: users
can sample weighted streams into `[N]T` without heap allocation when the requested
count is known at comptime.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
