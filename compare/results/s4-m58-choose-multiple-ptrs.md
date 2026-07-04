# S4-M58 Allocation-Returning Pointer Subset Sampling

Date: 2026-07-04

Purpose: extend allocation-returning item subset sampling with const and mutable
pointer outputs. This complements `chooseMultiple` value slices, S4-M52
caller-owned pointer buffers, and S4-M53 fixed-size pointer arrays while avoiding
value copies for allocation-returning workflows.

## Change

Added allocation-returning pointer subset helpers in `src/seq.zig`:

- `seq.chooseMultiplePtrs(allocator, rng, T, items, amount)`;
- `seq.chooseMultiplePtrsFrom(allocator, source, T, items, amount)`;
- `seq.chooseMultiplePtrsChecked(allocator, rng, T, items, amount)`;
- `seq.chooseMultiplePtrsCheckedFrom(allocator, source, T, items, amount)`;
- `seq.chooseMultipleMutPtrs(allocator, rng, T, items, amount)`;
- `seq.chooseMultipleMutPtrsFrom(allocator, source, T, items, amount)`;
- `seq.chooseMultipleMutPtrsChecked(allocator, rng, T, items, amount)`;
- `seq.chooseMultipleMutPtrsCheckedFrom(allocator, source, T, items, amount)`.

Optional forms return an allocated pointer slice of length `min(amount,
items.len)`. Checked forms require `amount <= items.len`. Mutable-pointer forms
sample without replacement and return distinct `*T` pointers for direct mutation
of selected items.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints allocation-returning const-pointer
  subset output and a mutable-pointer subset update workflow;
- `docs/examples.md` describes allocation-returning and caller-owned
  item/value/pointer subset buffers;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions allocation-returning and caller-owned item/pointer subsets;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M58 evidence.

## Validation

Commands:

```sh
git diff --check
zig build test
zig build run-sequence-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- optional and checked allocation-returning const-pointer subset slices;
- checked allocation-returning mutable-pointer subset slices that mutate items;
- zero-length no-consume behavior;
- facade/direct stream-shape parity;
- checked too-large invalid paths that do not consume RNG state;
- initial output allocation failures and later index-allocation failures that do
  not consume RNG state.

## S4-M58 Decision

S4-M58 is closed for the current allocation-returning pointer subset bar:
allocation-returning item subsets can now return const or mutable pointer slices
without copying selected item values.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
