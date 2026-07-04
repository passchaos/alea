# S4-M54 Fixed-Size Weighted Pointer Array Sampling

Date: 2026-07-04

Purpose: extend fixed-size weighted no-replacement item sampling with const and
mutable pointer array outputs. This complements S4-M37 `sampleWeightedArray`,
S4-M53 unweighted pointer arrays, and local Rust weighted slice-choice ergonomics
while avoiding heap allocation and value copies.

## Change

Added fixed-size weighted pointer array helpers in `src/seq.zig`:

- `seq.sampleWeightedPtrArray(rng, T, Weight, N, items, weights)`;
- `seq.sampleWeightedPtrArrayFrom(source, T, Weight, N, items, weights)`;
- `seq.sampleWeightedPtrArrayChecked(rng, T, Weight, N, items, weights)`;
- `seq.sampleWeightedPtrArrayCheckedFrom(source, T, Weight, N, items, weights)`;
- `seq.sampleWeightedMutPtrArray(rng, T, Weight, N, items, weights)`;
- `seq.sampleWeightedMutPtrArrayFrom(source, T, Weight, N, items, weights)`;
- `seq.sampleWeightedMutPtrArrayChecked(rng, T, Weight, N, items, weights)`;
- `seq.sampleWeightedMutPtrArrayCheckedFrom(source, T, Weight, N, items, weights)`.

The optional forms return `null` when there are fewer than `N` positive weights;
checked forms return `error.InvalidParameter` before exposing a partial result.
All forms share the existing fixed-size weighted index sampling path, so selected
pointers are distinct and stream shape matches value/index weighted arrays.
Mutable pointer forms return `[N]*T` for direct mutation of selected items.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints fixed-size weighted const-pointer array
  output and a mutable-pointer array update workflow;
- `docs/examples.md` describes fixed-size weighted item/index/pointer arrays;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions weighted fixed-size pointer arrays;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M54 evidence.

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

- optional and checked fixed-size weighted const-pointer arrays;
- checked fixed-size weighted mutable-pointer arrays that mutate selected items;
- single-positive no-consume behavior;
- zero-length arrays;
- optional too-few-positive `null` results;
- checked too-few-positive invalid paths;
- facade/direct stream-shape parity for const and mutable pointer arrays;
- length-mismatch and invalid-weight paths that do not consume RNG state.

## S4-M54 Decision

S4-M54 is closed for the current fixed-size weighted pointer array bar:
fixed-size weighted no-replacement item subsets can now return const or mutable
pointer arrays without heap allocation and without copying item values.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
