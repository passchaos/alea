# S4-M59 Allocation-Returning Weighted Pointer Subset Sampling

Date: 2026-07-04

Purpose: extend allocation-returning weighted no-replacement item sampling with
const and mutable pointer outputs. This complements `sampleWeighted` value slices,
S4-M55 caller-owned weighted pointer buffers, and S4-M54 fixed-size weighted
pointer arrays while avoiding value copies for allocation-returning weighted
workflows.

## Change

Added allocation-returning weighted pointer subset helpers in `src/seq.zig`:

- `seq.sampleWeightedPtrs(allocator, rng, T, Weight, items, weights, amount)`;
- `seq.sampleWeightedPtrsFrom(allocator, source, T, Weight, items, weights, amount)`;
- `seq.sampleWeightedPtrsChecked(allocator, rng, T, Weight, items, weights, amount)`;
- `seq.sampleWeightedPtrsCheckedFrom(allocator, source, T, Weight, items, weights, amount)`;
- `seq.sampleWeightedMutPtrs(allocator, rng, T, Weight, items, weights, amount)`;
- `seq.sampleWeightedMutPtrsFrom(allocator, source, T, Weight, items, weights, amount)`;
- `seq.sampleWeightedMutPtrsChecked(allocator, rng, T, Weight, items, weights, amount)`;
- `seq.sampleWeightedMutPtrsCheckedFrom(allocator, source, T, Weight, items, weights, amount)`.

Optional forms return allocated pointer slices of length `min(amount,
positive_weight_count)`. Checked forms require enough positive weights for the
requested amount. Mutable-pointer forms sample without replacement and return
distinct `*T` pointers for direct mutation of selected weighted items.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints allocation-returning weighted
  const-pointer subset output and a mutable-pointer subset update workflow;
- `docs/examples.md` describes allocation-returning weighted no-replacement
  item/index/pointer outputs;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions allocation-returning weighted pointer subsets;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M59 evidence.

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

- optional and checked allocation-returning weighted const-pointer subset slices;
- checked allocation-returning weighted mutable-pointer subset slices that mutate items;
- single-positive no-consume behavior;
- zero-length no-consume behavior;
- facade/direct stream-shape parity;
- length-mismatch and invalid-weight paths that do not consume RNG state;
- initial output allocation failures and later index-allocation failures that do
  not consume RNG state.

## S4-M59 Decision

S4-M59 is closed for the current allocation-returning weighted pointer subset
bar: allocation-returning weighted no-replacement item subsets can now return
const or mutable pointer slices without copying selected item values.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
