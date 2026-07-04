# S4-M69 Weighted IndexVec Sampling

Date: 2026-07-04

Purpose: add a compact `IndexVec` result shape for weighted no-replacement index
sampling. This complements unweighted `sampleIndexVec`, allocation-returning
`sampleWeightedIndices`, caller-owned weighted index buffers, and fixed-size
weighted index arrays.

## Change

Added weighted IndexVec helpers in `src/seq.zig`:

- `seq.sampleWeightedIndexVec(allocator, rng, Weight, weights, amount)`;
- `seq.sampleWeightedIndexVecFrom(allocator, source, Weight, weights, amount)`;
- `seq.sampleWeightedIndexVecChecked(allocator, rng, Weight, weights, amount)`;
- `seq.sampleWeightedIndexVecCheckedFrom(allocator, source, Weight, weights, amount)`.

The helpers return `IndexVec`, using compact `u32` backing when the weight slice
length fits. Optional forms return up to the available positive-weight count;
checked forms require enough positive-weight entries for the requested amount.
Zero-count and single-positive paths do not consume randomness.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints a `weighted IndexVec` row;
- `docs/examples.md` describes compact weighted IndexVec samples;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions compact weighted IndexVec samples;
- `tools/examplecheck.zig` guards the weighted example token;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M69 evidence.

## Validation

Commands:

```sh
git diff --check
zig build test
zig build run-weighted-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- optional and checked weighted `IndexVec` samples;
- compact `u32` backing for local-size weight slices;
- zero-count behavior;
- invalid empty/too-large/invalid-weight paths;
- example content drift token coverage.

## S4-M69 Decision

S4-M69 is closed for the current weighted `IndexVec` bar: weighted
no-replacement index samples can now use the same compact index-vector result
shape as unweighted index sampling.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
