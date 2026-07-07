# S4-M734 WeightedChoice Checked U32 Index Aliases

## Gap

Reusable `Choice` now has checked compact `u32` index aliases for scalar,
caller-owned, owned, fixed-array, and iterator output shapes. Reusable
`WeightedChoice` still lacked matching checked aliases for scalar, caller-owned,
owned, and iterator compact weighted index output shapes, while its fixed-array
compact `u32` path already had checked naming.

Reusable `WeightedChoice` should provide checked compact `u32` index aliases that
preserve stream shape while improving API consistency across weighted compact
index output shapes.

## Local `rand` Baseline

The local Rust `rand` checkout exposes weighted index/reference choice workflows.
Alea's reusable `WeightedChoice(T, Weight)` already provides compact `u32`
scalar, caller-owned, owned, fixed-array, and iterator weighted index outputs for
populations that fit `u32`; checked aliases make those compact weighted index
paths more discoverable while preserving Zig-native pointer/value/index output
families.

## API Added

`src/seq.zig` adds checked compact `u32` index aliases to
`WeightedChoice(T, Weight)`:

- `WeightedChoice(T, Weight).sampleIndexU32Checked`
- `WeightedChoice(T, Weight).sampleIndexU32CheckedFrom`
- `WeightedChoice(T, Weight).fillIndicesU32Checked`
- `WeightedChoice(T, Weight).fillIndicesU32CheckedFrom`
- `WeightedChoice(T, Weight).indicesU32Checked`
- `WeightedChoice(T, Weight).indicesU32CheckedFrom`
- `WeightedChoice(T, Weight).indexIterU32Checked`
- `WeightedChoice(T, Weight).indexIterU32CheckedFrom`

Existing fixed-array checked aliases remain unchanged:

- `WeightedChoice(T, Weight).indexArrayU32Checked`
- `WeightedChoice(T, Weight).indexArrayU32CheckedFrom`

The aliases delegate to existing compact `u32` weighted index output behavior.
`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Checked compact `u32` weighted index aliases preserve the stream shape of their
  existing compact index counterparts.
- Scalar/caller-owned/owned/fixed/iterator checked aliases are available for
  repeated compact weighted index output.
- Checked compact aliases preserve existing `error.InvalidParameter` behavior
  when the population does not fit `u32`.

## Adoption and Documentation

- Focused weighted-choice tests compare checked scalar compact indexes,
  caller-owned fills, owned batches, and iterators against their unchecked
  counterparts and confirm identical stream shape.
- Existing fixed-array checked tests continue to cover
  `indexArrayU32Checked*`.
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
apicheck ok
readmecheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M734 is closed for the current bar: reusable `WeightedChoice` now has checked
aliases for scalar, caller-owned, owned, fixed-size, and iterator compact
weighted `u32` index outputs. This is ergonomics/discoverability work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
