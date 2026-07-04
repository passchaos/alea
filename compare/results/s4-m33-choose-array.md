# S4-M33 Fixed-Size Item Array Sequence Sampling

Date: 2026-07-04

Purpose: close a small sequence-sampling ergonomics gap against local Rust
`rand` evidence. Rust slice sampling exposes `sample_array` for fixed-size item
samples; Alea already had fixed-size index arrays (`sampleArray`) and allocated
item samples (`chooseMultiple`), but not a direct allocation-free `[N]T` item
sample helper.

## Change

Added Zig-native fixed-size item helpers in `src/seq.zig`:

- `chooseArray(rng, T, N, items) ?[N]T`
- `chooseArrayFrom(source, T, N, items) ?[N]T`
- `chooseArrayChecked(rng, T, N, items) Error![N]T`
- `chooseArrayCheckedFrom(source, T, N, items) Error![N]T`

The optional forms return `null` when `N > items.len`, matching the non-throwing
shape of existing `sampleArray`. The checked forms return `error.InvalidParameter`
before drawing. The implementation reuses `sampleArrayFrom` for fixed-size index
selection, then copies selected items into a stack `[N]T`, avoiding heap
allocation for small fixed-size item samples.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints a `chooseArray` sample;
- `docs/examples.md` describes fixed-size item arrays in the sequence example;
- `docs/core-guide.md` and `docs/api-reference.md` list the new API;
- `README.md` mentions fixed-size item arrays in collection helpers;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` record the local Rust sequence
  ergonomics comparison.

## Validation

Commands:

```sh
zig build test
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- optional/direct and checked/facade forms;
- zero-length arrays;
- `N > items.len` optional `null` and checked `InvalidParameter` behavior;
- invalid checked calls preserving stream position;
- facade and direct-source stream-shape parity.

## S4-M33 Decision

S4-M33 is closed for the current fixed-size item sample bar: Alea now has an
allocation-free `[N]T` item sampling helper alongside existing fixed-size index
sampling, allocated item sampling, partial shuffle, and reservoir workflows.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
