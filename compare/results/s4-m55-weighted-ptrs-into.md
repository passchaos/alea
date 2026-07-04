# S4-M55 Caller-Owned Weighted Pointer Subset Sampling

Date: 2026-07-04

Purpose: extend runtime caller-owned weighted no-replacement item sampling with
const and mutable pointer outputs. This complements S4-M42 `sampleWeightedInto`,
S4-M52 unweighted pointer buffers, and S4-M54 fixed-size weighted pointer arrays
while avoiding heap allocation and value copies for runtime-length workflows.

## Change

Added caller-owned weighted pointer subset helpers in `src/seq.zig`:

- `seq.sampleWeightedPtrsInto(rng, T, Weight, items, weights, out, scratch_indices, scratch_keys)`;
- `seq.sampleWeightedPtrsIntoFrom(source, T, Weight, items, weights, out, scratch_indices, scratch_keys)`;
- `seq.sampleWeightedPtrsIntoChecked(rng, T, Weight, items, weights, out, scratch_indices, scratch_keys)`;
- `seq.sampleWeightedPtrsIntoCheckedFrom(source, T, Weight, items, weights, out, scratch_indices, scratch_keys)`;
- `seq.sampleWeightedMutPtrsInto(rng, T, Weight, items, weights, out, scratch_indices, scratch_keys)`;
- `seq.sampleWeightedMutPtrsIntoFrom(source, T, Weight, items, weights, out, scratch_indices, scratch_keys)`;
- `seq.sampleWeightedMutPtrsIntoChecked(rng, T, Weight, items, weights, out, scratch_indices, scratch_keys)`;
- `seq.sampleWeightedMutPtrsIntoCheckedFrom(source, T, Weight, items, weights, out, scratch_indices, scratch_keys)`.

The optional forms fill up to the available positive-weight count and return the
filled count. Checked forms require enough positive-weight entries for the output
length. All forms validate item/weight length and scratch buffer lengths before
drawing, then reuse the existing caller-owned weighted index path so selected
pointers are distinct and stream shape matches weighted value buffers.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints caller-owned weighted const-pointer
  buffer output and a mutable-pointer buffer update workflow;
- `docs/examples.md` describes caller-owned weighted index/value/pointer buffers;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions caller-owned weighted pointer buffers;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M55 evidence.

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

- optional and checked caller-owned weighted const-pointer buffers;
- checked caller-owned weighted mutable-pointer buffers that mutate selected items;
- single-positive no-consume behavior;
- zero-length no-consume behavior;
- facade/direct stream-shape parity for const and mutable pointer buffers;
- scratch-length, item/weight length-mismatch, and invalid-weight paths that do
  not consume RNG state.

## S4-M55 Decision

S4-M55 is closed for the current caller-owned weighted pointer subset bar:
runtime-length weighted no-replacement item subsets can now fill caller-owned
const or mutable pointer buffers using caller-provided index/key scratch, without
heap allocation and without copying item values.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
