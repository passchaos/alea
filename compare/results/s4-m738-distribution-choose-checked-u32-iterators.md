# S4-M738 Distribution Choose Checked U32 Iterators

## Gap

Distribution-layer `Choose` already exposed compact `u32` index iterators through
`indexIterU32*`, and checked iterator aliases for value, pointer, and `usize`
index iterator workflows. It still lacked checked aliases for compact `u32` index
iterators, leaving compact iterator naming less consistent with reusable
`Choice` / `WeightedChoice` and the rest of the distribution-layer checked index
surface.

Distribution-layer `Choose` should provide checked compact `u32` iterator aliases
that preserve stream shape and existing width validation.

## Local `rand` Baseline

The local Rust `rand` checkout exposes repeated slice choice workflows through
reference/index-oriented iterator collection. Alea's distribution-layer
`Choose(T)` already provides compact `u32` index iterators for populations that
fit `u32`; checked aliases make this compact iterator path more discoverable
while preserving Zig-native pointer/value/index output families.

## API Added

`src/distributions.zig` adds checked compact `u32` iterator aliases to
`Choose(T)`:

- `Choose(T).indexIterU32Checked`
- `Choose(T).indexIterU32CheckedFrom`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Checked compact `u32` iterator aliases preserve `indexIterU32From` stream
  shape.
- Checked compact aliases preserve existing `error.InvalidParameter` behavior
  when the population does not fit `u32`.

## Adoption and Documentation

- Focused distribution tests compare checked and unchecked compact `u32` iterator
  scalar draws for stream parity.
- Existing tests continue to cover `indexIterU32From` fill behavior and compact
  `u32` width validation through the shared constructor path.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "distribution Choose sampler mirrors slice choices"
1/2 distributions.test.distribution Choose sampler mirrors slice choices...OK
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
roadmapcheck ok
apicheck ok
examplecheck ok
readmecheck ok
```

## Result

S4-M738 is closed for the current bar: distribution-layer `Choose` now has
checked aliases for compact `u32` index iterators. This is
ergonomics/discoverability work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
