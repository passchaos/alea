# S4-M46 Partial Shuffle Split Result

Date: 2026-07-04

Purpose: improve partial-shuffle ergonomics by exposing both the selected head
and the remaining tail. Rust slice `partial_shuffle` returns both pieces;
Alea's existing `partialShuffle` returned only the selected head.

## Change

Added split-result helpers in `src/seq.zig`:

- `PartialShuffleSplit(T)` result type with `selected: []T` and `rest: []T`
- `partialShuffleSplit(rng, T, items, amount) PartialShuffleSplit(T)`
- `partialShuffleSplitFrom(source, T, items, amount) PartialShuffleSplit(T)`
- `partialShuffleSplitChecked(rng, T, items, amount) Error!PartialShuffleSplit(T)`
- `partialShuffleSplitCheckedFrom(source, T, items, amount) Error!PartialShuffleSplit(T)`

The split helpers reuse the existing in-place partial shuffle and return
`items[0..count]` as `selected` plus `items[count..]` as `rest`. Checked forms
reject `amount > items.len` before drawing. Existing head-only `partialShuffle*`
APIs remain unchanged.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints a `partialShuffleSplit` sample and rest
  length;
- `docs/examples.md` describes selected/rest partial-shuffle splits;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions selected/rest partial shuffle workflows.

## Validation

Commands:

```sh
zig build test
zig build run-sequence-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- split selected/rest lengths and returned slices;
- checked invalid-count no-consume behavior;
- zero-count no-mutate/no-consume behavior;
- facade/direct stream-shape parity.

## S4-M46 Decision

S4-M46 is closed for the current partial-shuffle split bar: users can now choose
head-only or selected/rest in-place partial shuffle workflows.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
