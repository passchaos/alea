# S4-M73 Fixed-Size U32 Index Arrays

Date: 2026-07-04

Purpose: add a compact fixed-size output shape for unweighted index sampling.
This complements allocation-returning `sampleIndicesU32`, caller-owned
`sampleIndicesU32Into`, compact `IndexVec`, and existing `[N]usize`
`sampleArray` helpers.

## Change

Added fixed-size `u32` index helpers in `src/seq.zig`:

- `seq.sampleArrayU32(rng, N, length)`;
- `seq.sampleArrayU32From(source, N, length)`;
- `seq.sampleArrayU32Checked(rng, N, length)`;
- `seq.sampleArrayU32CheckedFrom(source, N, length)`.

The optional forms return `null` when `N > length`. Checked forms return
`error.InvalidParameter` before drawing in that case. Zero-count forms return an
empty array before drawing even for non-empty populations.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints a `sampleArrayU32` row;
- `docs/examples.md` describes compact fixed-size u32 index arrays;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions fixed-size u32 index arrays;
- `tools/examplecheck.zig` guards the sequence example token;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M73 evidence.

## Validation

Commands for final validation:

```sh
git diff --check
zig build test
zig build run-sequence-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- optional and checked fixed-size `u32` index arrays;
- direct-source/facade stream-shape parity;
- zero-count no-consume behavior;
- invalid checked-count no-consume behavior;
- bounds checks for sampled indexes.

## S4-M73 Decision

S4-M73 is closed for the current compact fixed-size unweighted index bar:
unweighted index samples can now return heap-free `[N]u32` arrays directly when
the population length fits the compact index width.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
