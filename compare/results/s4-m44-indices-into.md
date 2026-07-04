# S4-M44 Caller-Owned Index Sampling

Date: 2026-07-04

Purpose: add runtime-length caller-owned index sampling. Alea already had
allocation-returning `sampleIndices`, compact `IndexVec`, and fixed-size
`sampleArray`; this milestone adds a buffer-fill form for callers that can
provide output storage.

## Change

Added caller-owned index helpers in `src/seq.zig`:

- `sampleIndicesInto(rng, length, out) Error!void`
- `sampleIndicesIntoFrom(source, length, out) void`
- `sampleIndicesIntoChecked(rng, length, out) Error!void`
- `sampleIndicesIntoCheckedFrom(source, length, out) Error!void`

The checked/facade forms reject `out.len > length` before drawing. Zero-length
output returns immediately without consuming randomness. The implementation uses
the same Floyd-style selection shape as fixed-size `sampleArrayFrom`, filling the
caller-owned `out` buffer without heap allocation.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints `sampleIndicesInto` output;
- `docs/examples.md` describes caller-owned index buffers;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions caller-owned index sampling.

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

- checked/facade and direct-source forms;
- zero-length no-consume behavior;
- invalid length no-consume behavior;
- facade/direct stream-shape parity.

## S4-M44 Decision

S4-M44 is closed for the current caller-owned index sampling bar: users can now
choose allocation-returning, compact, fixed-size, or caller-owned index workflows.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
