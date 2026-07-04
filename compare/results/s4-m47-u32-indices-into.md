# S4-M47 Caller-Owned U32 Index Sampling

Date: 2026-07-04

Purpose: add caller-owned compact `u32` index sampling. S4-M44 added
caller-owned native-`usize` index buffers; this milestone adds the same buffer
workflow for `u32` indexes when the sampled population fits in `u32`.

## Change

Added caller-owned compact index helpers in `src/seq.zig`:

- `sampleIndicesU32Into(rng, length, out) Error!void`
- `sampleIndicesU32IntoFrom(source, length, out) void`
- `sampleIndicesU32IntoChecked(rng, length, out) Error!void`
- `sampleIndicesU32IntoCheckedFrom(source, length, out) Error!void`

The checked/facade forms reject `out.len > length` before drawing. Zero-length
output returns immediately without consuming randomness. The implementation uses
a Floyd-style selection shape over `u32` values and fills the caller-owned `out`
buffer without heap allocation.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints `sampleIndicesU32Into` output;
- `docs/examples.md` describes caller-owned `usize`/`u32` index buffers;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions caller-owned `usize`/`u32` index sampling.

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

## S4-M47 Decision

S4-M47 is closed for the current caller-owned compact index sampling bar: users
can now choose allocation-returning or caller-owned `usize`/`u32` index workflows.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
