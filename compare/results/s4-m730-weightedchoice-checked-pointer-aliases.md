# S4-M730 WeightedChoice Checked Pointer Aliases

## Gap

Reusable `Choice` now has checked pointer aliases for caller-owned fills, owned
pointer batches, and fixed pointer arrays. Reusable `WeightedChoice` still lacked
matching checked aliases for its weighted pointer output families.

Reusable `WeightedChoice` should provide checked pointer aliases that preserve
stream shape while improving API consistency across weighted pointer output
shapes.

## Local `rand` Baseline

The local Rust `rand` checkout exposes weighted reference-oriented choice
workflows. Alea's reusable `WeightedChoice(T, Weight)` already provides weighted
pointer outputs for repeated reference sampling; checked pointer aliases make
those reference-oriented paths more discoverable while preserving Zig-native
pointer/value/index output families.

## API Added

`src/seq.zig` adds checked pointer aliases to `WeightedChoice(T, Weight)`:

- `WeightedChoice(T, Weight).fillChecked`
- `WeightedChoice(T, Weight).fillCheckedFrom`
- `WeightedChoice(T, Weight).ptrsChecked`
- `WeightedChoice(T, Weight).ptrsCheckedFrom`
- `WeightedChoice(T, Weight).ptrArrayChecked`
- `WeightedChoice(T, Weight).ptrArrayCheckedFrom`

The aliases delegate to existing weighted pointer output behavior.
`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Checked pointer aliases preserve the stream shape of their existing weighted
  pointer counterparts.
- Owned/fixed/caller-owned checked aliases are available for repeated weighted
  pointer output.
- Checked pointer aliases do not introduce new failure modes because successful
  `WeightedChoice` construction already validates items and weights.

## Adoption and Documentation

- Focused weighted-choice tests compare checked pointer fill, owned pointer
  output, and fixed pointer arrays against their unchecked counterparts and
  confirm identical stream shape.
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
examplecheck ok
roadmapcheck ok
readmecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M730 is closed for the current bar: reusable `WeightedChoice` now has checked
aliases for caller-owned, owned, and fixed-size weighted pointer outputs. This is
ergonomics/discoverability work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
