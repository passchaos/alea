# S4-M40 Fixed-Size Iterator Array Sampling

Date: 2026-07-04

Purpose: complement allocation-returning `sampleIterator` and caller-owned
`sampleIteratorInto` with a fixed-size `[N]T` helper for streaming iterators when
the requested count is known at comptime.

## Change

Added fixed-size iterator helpers in `src/seq.zig`:

- `sampleIteratorArray(rng, T, N, iterator) ?[N]T`
- `sampleIteratorArrayFrom(source, T, N, iterator) ?[N]T`
- `sampleIteratorArrayChecked(rng, T, N, iterator) Error![N]T`
- `sampleIteratorArrayCheckedFrom(source, T, N, iterator) Error![N]T`

The optional forms return `null` when the stream is too short. The checked forms
return `error.InvalidParameter` before drawing when the stream is too short.
Zero-length requests do not read the iterator or consume randomness. The
implementation uses a stack `[N]T` reservoir and therefore avoids heap allocation
for fixed-size iterator samples.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints a fixed-size iterator array sample;
- `docs/examples.md` describes fixed-size iterator helpers;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions fixed-size iterator sampling.

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
- short-stream optional `null` and checked `InvalidParameter` behavior;
- zero-length no-read/no-consume behavior;
- facade/direct stream-shape parity.

## S4-M40 Decision

S4-M40 is closed for the current fixed-size iterator array bar: users can sample
streaming iterators into `[N]T` without heap allocation when the requested count
is known at comptime.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
