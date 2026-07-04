# S4-M71 Fixed-Size Weighted U32 Index Arrays

Date: 2026-07-04

Purpose: add a compact fixed-size output shape for weighted no-replacement index
sampling. This complements `sampleWeightedIndexArray` (`[N]usize` output),
S4-M70's caller-owned `u32` buffers, and S4-M69's compact weighted `IndexVec`.

## Change

Added fixed-size weighted `u32` index helpers in `src/seq.zig`:

- `seq.sampleWeightedIndexArrayU32(rng, Weight, N, weights)`;
- `seq.sampleWeightedIndexArrayU32From(source, Weight, N, weights)`;
- `seq.sampleWeightedIndexArrayU32Checked(rng, Weight, N, weights)`;
- `seq.sampleWeightedIndexArrayU32CheckedFrom(source, Weight, N, weights)`.

The optional forms return `null` when fewer than `N` positive-weight entries are
available. Checked forms require enough positive-weight entries. All non-empty
forms require `weights.len <= maxInt(u32)` so returned indexes are representable
in the compact fixed-size result.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints a `weighted u32 index array` row;
- `docs/examples.md` describes fixed-size weighted `u32` index arrays;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions fixed-size weighted u32 index arrays;
- `tools/examplecheck.zig` guards the weighted example token;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M71 evidence.

## Validation

Commands for final validation:

```sh
git diff --check
zig build test
zig build run-weighted-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- optional and checked fixed-size weighted `u32` index arrays;
- direct-source/facade stream-shape parity;
- zero-count no-consume behavior;
- single-positive no-consume behavior;
- too-large checked-count and invalid-weight no-consume errors.

## S4-M71 Decision

S4-M71 is closed for the current compact fixed-size weighted index bar: weighted
no-replacement index samples can now return heap-free `[N]u32` arrays directly
when the weight slice fits the compact index width.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
