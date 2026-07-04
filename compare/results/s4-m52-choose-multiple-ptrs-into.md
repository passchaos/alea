# S4-M52 Caller-Owned Pointer Subset Sampling

Date: 2026-07-04

Purpose: extend caller-owned item subset sampling with const and mutable pointer
outputs. This complements S4-M45 `chooseMultipleInto` value buffers and local
Rust mutable slice-choice ergonomics while keeping Alea's Zig-native explicit
scratch-buffer style.

## Change

Added caller-owned pointer subset helpers in `src/seq.zig`:

- `seq.chooseMultiplePtrsInto(rng, T, items, out, scratch_indices)`;
- `seq.chooseMultiplePtrsIntoFrom(source, T, items, out, scratch_indices)`;
- `seq.chooseMultiplePtrsIntoChecked(rng, T, items, out, scratch_indices)`;
- `seq.chooseMultiplePtrsIntoCheckedFrom(source, T, items, out, scratch_indices)`;
- `seq.chooseMultipleMutPtrsInto(rng, T, items, out, scratch_indices)`;
- `seq.chooseMultipleMutPtrsIntoFrom(source, T, items, out, scratch_indices)`;
- `seq.chooseMultipleMutPtrsIntoChecked(rng, T, items, out, scratch_indices)`;
- `seq.chooseMultipleMutPtrsIntoCheckedFrom(source, T, items, out, scratch_indices)`.

The optional forms fill up to `min(out.len, items.len)` pointers and return the
filled count. The checked forms require `out.len <= items.len`. All forms require
caller-provided index scratch and validate scratch length before drawing, so
invalid buffer shapes do not consume randomness. Mutable pointer forms sample
without replacement, so the returned pointers are distinct when the input slice
is distinct.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints const-pointer subset output and a
  mutable-pointer subset update workflow;
- `docs/examples.md` describes caller-owned item/value/pointer subset buffers;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions caller-owned pointer subsets;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M52 evidence.

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

- optional const-pointer subset buffers with partial-fill behavior;
- checked const-pointer subset buffers;
- checked mutable-pointer subset buffers that mutate selected items;
- zero-length no-consume behavior;
- facade/direct stream-shape parity;
- scratch-length and too-many-output invalid paths that do not consume RNG state.

## S4-M52 Decision

S4-M52 is closed for the current caller-owned pointer subset bar: runtime-length
item subsets can now fill caller-owned const or mutable pointer buffers using
caller-provided scratch, without heap allocation and without copying item values.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
