# S4-M60 Allocation-Returning Reservoir Pointer Sampling

Date: 2026-07-04

Purpose: extend allocation-returning reservoir sampling with const and mutable
pointer outputs. This complements `reservoirSample` value slices and the recent
pointer subset APIs while avoiding value copies for reservoir workflows.

## Change

Added allocation-returning reservoir pointer helpers in `src/seq.zig`:

- `seq.reservoirSamplePtrs(allocator, rng, T, items, amount)`;
- `seq.reservoirSamplePtrsFrom(allocator, source, T, items, amount)`;
- `seq.reservoirSamplePtrsChecked(allocator, rng, T, items, amount)`;
- `seq.reservoirSamplePtrsCheckedFrom(allocator, source, T, items, amount)`;
- `seq.reservoirSampleMutPtrs(allocator, rng, T, items, amount)`;
- `seq.reservoirSampleMutPtrsFrom(allocator, source, T, items, amount)`;
- `seq.reservoirSampleMutPtrsChecked(allocator, rng, T, items, amount)`;
- `seq.reservoirSampleMutPtrsCheckedFrom(allocator, source, T, items, amount)`.

Optional forms return an allocated pointer slice of length `min(amount,
items.len)`. Checked forms require `amount <= items.len`. Mutable-pointer forms
use the same reservoir stream shape and return distinct `*T` pointers for direct
mutation of selected items.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints allocation-returning const-pointer
  reservoir output and a mutable-pointer reservoir update workflow;
- `docs/examples.md` describes allocated value/pointer and caller-owned reservoir
  sampling;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions allocated value/pointer reservoir sampling;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M60 evidence.

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

- optional and checked allocation-returning const-pointer reservoir slices;
- checked allocation-returning mutable-pointer reservoir slices that mutate items;
- zero-length no-consume behavior;
- facade/direct stream-shape parity;
- checked too-large invalid paths that do not consume RNG state;
- initial allocation failures that do not consume RNG state.

## S4-M60 Decision

S4-M60 is closed for the current reservoir pointer bar: allocation-returning
reservoir samples can now return const or mutable pointer slices without copying
selected item values.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
