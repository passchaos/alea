# S4-M34 One-Shot Weighted Item And Pointer Choice

Date: 2026-07-04

Purpose: close a small sequence-sampling ergonomics gap against local Rust
`rand` weighted slice-choice evidence. Alea already exposed weighted indexes,
reusable `WeightedChoice`, weighted iterator helpers, and weighted
no-replacement sampling; this milestone adds direct one-shot weighted item and
mutable-pointer selection for slice workflows.

## Change

Added one-shot weighted slice helpers in `src/seq.zig`:

- `chooseWeighted(rng, T, Weight, items, weights) !?T`
- `chooseWeightedFrom(source, T, Weight, items, weights) !?T`
- `chooseWeightedChecked(rng, T, Weight, items, weights) !T`
- `chooseWeightedCheckedFrom(source, T, Weight, items, weights) !T`
- `chooseWeightedPtr(rng, T, Weight, items, weights) !?*T`
- `chooseWeightedPtrFrom(source, T, Weight, items, weights) !?*T`
- `chooseWeightedPtrChecked(rng, T, Weight, items, weights) !*T`
- `chooseWeightedPtrCheckedFrom(source, T, Weight, items, weights) !*T`

The optional forms return `null` for empty/all-zero weights. Checked forms return
`error.EmptyInput` in that case. All forms reject length mismatches and invalid
weights before drawing. Single-positive-weight inputs return the corresponding
item or pointer without consuming randomness.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints a `chooseWeighted` value;
- `docs/examples.md` describes one-shot weighted indexes and values;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions one-shot weighted item/pointer helpers;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` record the local Rust weighted
  slice-choice comparison.

## Validation

Commands:

```sh
zig build test
zig build run-weighted-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- optional, checked, facade, and direct-source forms;
- value and mutable-pointer selection;
- empty/all-zero optional and checked behavior;
- single-positive no-consume behavior;
- length-mismatch and invalid-weight no-consume behavior;
- facade/direct stream-shape parity.

## S4-M34 Decision

S4-M34 is closed for the current one-shot weighted slice-choice bar: Alea now
covers weighted indexes, one-shot weighted values/pointers, reusable weighted
choices, weighted iterators, and weighted no-replacement workflows in Zig-native
form.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
