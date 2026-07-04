# S4-M36 Caller-Owned Iterator Reservoir Sampling

Date: 2026-07-04

Purpose: improve streaming sequence ergonomics after caller-owned slice reservoir
sampling. Local Rust `rand` exposes iterator sample-fill workflows; Alea already
had allocation-returning iterator sampling, and this milestone adds caller-owned
buffer forms.

## Change

Added caller-owned iterator reservoir helpers in `src/seq.zig`:

- `sampleIteratorInto(rng, T, iterator, out) usize`
- `sampleIteratorIntoFrom(source, T, iterator, out) usize`
- `sampleIteratorIntoChecked(rng, T, iterator, out) Error!void`
- `sampleIteratorIntoCheckedFrom(source, T, iterator, out) Error!void`

The optional forms fill up to `out.len` values and return the number actually
filled, so short streams are allowed without allocation. The checked forms
require enough iterator items to fill `out` and return `error.InvalidParameter`
before drawing when the stream is too short. Zero-length output returns
immediately without reading the iterator or consuming randomness.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints `sampleIteratorIntoFrom` output;
- `docs/examples.md` describes allocation-returning and caller-owned streaming
  iterator helpers;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions caller-owned iterator sampling.

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

- caller-owned optional and checked iterator reservoir fills;
- short-stream optional partial fills;
- checked short-stream no-consume behavior;
- zero-length no-read/no-consume behavior;
- facade/direct stream-shape parity.

## S4-M36 Decision

S4-M36 is closed for the current caller-owned iterator reservoir sampling bar:
users can sample streaming iterators into their own buffers or request checked
exact fills without heap allocation.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
