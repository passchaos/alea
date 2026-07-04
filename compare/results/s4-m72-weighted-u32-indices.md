# S4-M72 Allocation-Returning Weighted U32 Index Slices

Date: 2026-07-04

Purpose: add a compact allocation-returning output shape for weighted
no-replacement index sampling. This complements `sampleWeightedIndices`
(`[]usize` output), S4-M70 caller-owned `u32` buffers, S4-M71 fixed-size `u32`
arrays, and S4-M69 compact weighted `IndexVec`.

## Change

Added allocation-returning weighted `u32` index helpers in `src/seq.zig`:

- `seq.sampleWeightedIndicesU32(allocator, rng, Weight, weights, amount)`;
- `seq.sampleWeightedIndicesU32From(allocator, source, Weight, weights, amount)`;
- `seq.sampleWeightedIndicesU32Checked(allocator, rng, Weight, weights, amount)`;
- `seq.sampleWeightedIndicesU32CheckedFrom(allocator, source, Weight, weights, amount)`.

The optional forms return up to the available positive-weight count. Checked
forms require enough positive-weight entries for the requested amount. All
non-empty forms require `weights.len <= maxInt(u32)` so returned indexes are
representable in the compact owned slice.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints a `weighted u32 no-replacement indices` row;
- `docs/examples.md` describes allocation-returning weighted `u32` index outputs;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions allocation-returning weighted u32 index slices;
- `tools/examplecheck.zig` guards the weighted example token;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M72 evidence.

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

- optional and checked allocation-returning weighted `u32` index slices;
- direct-source/facade stream-shape parity;
- zero-count no-consume behavior;
- single-positive no-consume behavior;
- empty-input, too-large checked-count, and invalid-weight errors.

## S4-M72 Decision

S4-M72 is closed for the current compact allocation-returning weighted index
bar: weighted no-replacement index samples can now return owned `[]u32` slices
directly when the weight slice fits the compact index width.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
