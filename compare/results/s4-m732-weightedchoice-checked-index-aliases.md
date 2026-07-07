# S4-M732 WeightedChoice Checked Index Aliases

## Gap

Reusable `Choice` now has checked aliases for scalar, caller-owned, owned,
fixed-array, and iterator `usize` index output shapes. Reusable `WeightedChoice`
still lacked matching checked aliases for its weighted `usize` index output
families, while its compact `u32` fixed-array path already had checked naming.

Reusable `WeightedChoice` should provide checked `usize` index aliases that
preserve stream shape while improving API consistency across weighted index
output shapes.

## Local `rand` Baseline

The local Rust `rand` checkout exposes weighted index/reference choice workflows.
Alea's reusable `WeightedChoice(T, Weight)` already provides scalar,
caller-owned, owned, fixed-array, and iterator weighted index outputs; checked
aliases make those index-oriented paths more discoverable while preserving
Zig-native pointer/value/index output families.

## API Added

`src/seq.zig` adds checked `usize` index aliases to
`WeightedChoice(T, Weight)`:

- `WeightedChoice(T, Weight).sampleIndexChecked`
- `WeightedChoice(T, Weight).sampleIndexCheckedFrom`
- `WeightedChoice(T, Weight).fillIndicesChecked`
- `WeightedChoice(T, Weight).fillIndicesCheckedFrom`
- `WeightedChoice(T, Weight).indicesChecked`
- `WeightedChoice(T, Weight).indicesCheckedFrom`
- `WeightedChoice(T, Weight).indexArrayChecked`
- `WeightedChoice(T, Weight).indexArrayCheckedFrom`
- `WeightedChoice(T, Weight).indexIterChecked`
- `WeightedChoice(T, Weight).indexIterCheckedFrom`

The aliases delegate to existing weighted `usize` index output behavior.
`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Checked weighted `usize` index aliases preserve the stream shape of their
  existing index counterparts.
- Scalar/caller-owned/owned/fixed/iterator checked aliases are available for
  repeated weighted index output.
- Checked `usize` aliases do not introduce new failure modes because successful
  `WeightedChoice` construction already validates items and weights, and `usize`
  indexes do not need width checks.

## Adoption and Documentation

- Focused weighted-choice tests compare checked scalar indexes, caller-owned
  fills, owned batches, fixed arrays, and iterators against their unchecked
  counterparts and confirm identical stream shape.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq test:

```text
$ zig test src/seq.zig --test-filter "weighted choice sampler maps alias indexes to items"
1/2 seq.test.weighted choice sampler maps alias indexes to items...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

No output.

Broader native test gate:

```text
$ zig build test
toolingcheck ok
apicheck ok
examplecheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M732 is closed for the current bar: reusable `WeightedChoice` now has checked
aliases for scalar, caller-owned, owned, fixed-size, and iterator weighted
`usize` index outputs. This is ergonomics/discoverability work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
