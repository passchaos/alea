# S4-M61 Caller-Owned Reservoir Pointer Sampling

Date: 2026-07-04

Purpose: extend caller-owned reservoir sampling with const and mutable pointer
outputs. This complements `reservoirSampleInto`, S4-M60 allocation-returning
reservoir pointer slices, and the recent pointer subset APIs while avoiding value
copies for allocation-predictable reservoir workflows.

## Change

Added caller-owned reservoir pointer helpers in `src/seq.zig`:

- `seq.reservoirSamplePtrsInto(rng, T, items, out)`;
- `seq.reservoirSamplePtrsIntoFrom(source, T, items, out)`;
- `seq.reservoirSampleMutPtrsInto(rng, T, items, out)`;
- `seq.reservoirSampleMutPtrsIntoFrom(source, T, items, out)`.

The helpers fill caller-owned pointer buffers and reject `out.len > items.len`
before drawing. Mutable-pointer forms use the same reservoir stream shape and
return distinct `*T` pointers for direct mutation of selected items.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints caller-owned const-pointer reservoir
  output and a mutable-pointer reservoir update workflow;
- `docs/examples.md` describes allocated/caller-owned value and pointer reservoir
  sampling;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions allocated/caller-owned value and pointer reservoir sampling;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M61 evidence.

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

- caller-owned const-pointer reservoir buffers;
- caller-owned mutable-pointer reservoir buffers that mutate selected items;
- zero-length no-consume behavior;
- facade/direct stream-shape parity;
- checked too-large invalid paths that do not consume RNG state.

## S4-M61 Decision

S4-M61 is closed for the current caller-owned reservoir pointer bar:
caller-owned reservoir samples can now fill const or mutable pointer buffers
without copying selected item values.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
