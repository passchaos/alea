# S4-M143 Index-Weighted Item Choices

Result: passed.

Purpose: select weighted values, const pointers, and mutable pointers from an
item slice using a comptime index-weight function. S4-M140 through S4-M142 added
one-shot, caller-owned fill, and allocation-returning index outputs from
`length + weightFn(index)`. This milestone maps those same index-weighted draws
back to item slices so callers do not need a parallel weight slice or a manual
index-to-item conversion step.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs` and
`/home/passchaos/Work/rand/src/seq/index.rs`:

- `IndexedRandom::choose_weighted(rng, |item| ...)` builds a weighted-index
  distribution over slice positions and maps the selected index back to a
  reference;
- `IndexedMutRandom::choose_weighted_mut(rng, |item| ...)` does the mutable
  pointer equivalent;
- `index::sample_weighted(rng, length, |index| ..., amount)` demonstrates the
  local Rust length/index-weight accessor shape.

Alea already supports item-accessor weighted choices and index-weighted index
choices. This milestone combines those two ergonomics in Zig-native form:
weights can be indexed by position while the returned result is a value or
pointer from the item slice.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.chooseWeightedByIndex`;
- `seq.chooseWeightedByIndexFrom`;
- `seq.chooseWeightedByIndexChecked`;
- `seq.chooseWeightedByIndexCheckedFrom`;
- `seq.chooseWeightedConstPtrByIndex`;
- `seq.chooseWeightedConstPtrByIndexFrom`;
- `seq.chooseWeightedConstPtrByIndexChecked`;
- `seq.chooseWeightedConstPtrByIndexCheckedFrom`;
- `seq.chooseWeightedPtrByIndex`;
- `seq.chooseWeightedPtrByIndexFrom`;
- `seq.chooseWeightedPtrByIndexChecked`;
- `seq.chooseWeightedPtrByIndexCheckedFrom`.

Optional one-shot helpers return `null` for empty slices or all-zero
index-derived weights. Checked helpers reject those paths with
`error.EmptyInput`. Invalid negative, NaN, infinite, or overflowing weights
return `error.InvalidWeight`. Single-positive weights return deterministically
without consuming randomness.

Focused tests verify:

- value, const-pointer, and mutable-pointer outputs;
- checked and optional forms;
- facade/direct stream-shape parity for `ScalarPrng` and `DefaultPrng`;
- empty/all-zero optional no-consume behavior;
- checked empty/all-zero no-consume behavior;
- single-positive no-consume behavior;
- invalid-weight no-consume behavior.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `weighted index-weight value`,
  `weighted index-weight const ptr`, and `weighted index-weight mut ptr value`
  rows.
- `tools/examplecheck.zig` verifies those example tokens and the summary token.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the index-weighted item choice helpers.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "chooseWeightedByIndex"`
- `zig build test`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked weighted sequence ergonomics gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
