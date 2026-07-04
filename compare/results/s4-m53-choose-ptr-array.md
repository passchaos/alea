# S4-M53 Fixed-Size Pointer Array Sampling

Date: 2026-07-04

Purpose: extend fixed-size item-array sampling with const and mutable pointer
array outputs. This complements S4-M33 `chooseArray` value arrays and S4-M52
runtime caller-owned pointer buffers, while avoiding heap allocation and value
copies for fixed-size subset workflows.

## Change

Added fixed-size pointer array helpers in `src/seq.zig`:

- `seq.choosePtrArray(rng, T, N, items)`;
- `seq.choosePtrArrayFrom(source, T, N, items)`;
- `seq.choosePtrArrayChecked(rng, T, N, items)`;
- `seq.choosePtrArrayCheckedFrom(source, T, N, items)`;
- `seq.chooseMutPtrArray(rng, T, N, items)`;
- `seq.chooseMutPtrArrayFrom(source, T, N, items)`;
- `seq.chooseMutPtrArrayChecked(rng, T, N, items)`;
- `seq.chooseMutPtrArrayCheckedFrom(source, T, N, items)`.

The optional forms return `null` when `N > items.len`; checked forms return
`error.InvalidParameter` before drawing. All forms use `sampleArrayFrom`, so
selected pointers are distinct and the stream shape matches fixed-size index and
value-array sampling. Mutable pointer forms return `[N]*T` for direct mutation of
selected slice elements.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints fixed-size const-pointer array output
  and a mutable-pointer array update workflow;
- `docs/examples.md` describes fixed-size value/pointer arrays;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions fixed-size item/pointer arrays;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M53 evidence.

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

- optional and checked fixed-size const-pointer arrays;
- checked fixed-size mutable-pointer arrays that mutate selected items;
- zero-length arrays;
- optional too-large `null` results;
- checked too-large invalid paths that do not consume RNG state;
- facade/direct stream-shape parity for const and mutable pointer arrays.

## S4-M53 Decision

S4-M53 is closed for the current fixed-size pointer array bar: fixed-size item
subsets can now return const or mutable pointer arrays without heap allocation
and without copying item values.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
