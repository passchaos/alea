# S4-M70 Caller-Owned Weighted U32 Index Sampling

Date: 2026-07-04

Purpose: add a compact caller-owned output shape for weighted no-replacement
index sampling. This complements `sampleWeightedIndicesInto` (`usize` output),
fixed-size weighted index arrays, and S4-M69's compact allocation-returning
`sampleWeightedIndexVec` helper.

## Change

Added caller-owned weighted `u32` index helpers in `src/seq.zig`:

- `seq.sampleWeightedIndicesU32Into(rng, Weight, weights, out, scratch_keys)`;
- `seq.sampleWeightedIndicesU32IntoFrom(source, Weight, weights, out, scratch_keys)`;
- `seq.sampleWeightedIndicesU32IntoChecked(rng, Weight, weights, out, scratch_keys)`;
- `seq.sampleWeightedIndicesU32IntoCheckedFrom(source, Weight, weights, out, scratch_keys)`.

The optional forms fill up to the available positive-weight count and return the
number of written indexes. Checked forms require enough positive-weight entries
for the caller-owned output length. All forms require `weights.len <= maxInt(u32)`
so returned indexes are representable in the compact output buffer.

The compact `sampleWeightedIndexVec` implementation now reuses the `u32` exact
sampler for `.u32` output instead of allocating temporary `usize` index scratch
and narrowing after sampling.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints a `weighted u32 indices into` row;
- `docs/examples.md` describes caller-owned weighted usize/u32 index buffers;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions caller-owned weighted u32 index buffers;
- `tools/examplecheck.zig` guards the weighted example token;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M70 evidence.

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

- optional and checked weighted `u32` caller-owned index buffers;
- direct-source/facade stream-shape parity;
- zero-count no-consume behavior;
- single-positive no-consume behavior;
- scratch length, checked-count, empty-input, and invalid-weight errors;
- compact `sampleWeightedIndexVec` using the `u32` exact path.

## S4-M70 Decision

S4-M70 is closed for the current compact weighted caller-owned index bar:
weighted no-replacement index samples can now fill caller-owned `u32` output
buffers directly, and compact weighted `IndexVec` results avoid temporary
`usize` scratch for their sampled indexes.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
