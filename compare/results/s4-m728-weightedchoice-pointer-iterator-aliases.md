# S4-M728 WeightedChoice Pointer Iterator Aliases

## Gap

Reusable `Choice` now exposes explicit `ptrIter*` aliases for pointer iterator
discoverability. Reusable `WeightedChoice` still only exposed generic `iter*`
pointer iterators plus owned iterator variants, leaving weighted pointer iterator
discovery less consistent with `Choice`, distribution-layer `Choose`, and
checked alias naming.

Reusable `WeightedChoice` should expose explicit pointer iterator aliases that
preserve existing weighted pointer iterator stream shape and add checked aliases
for API consistency.

## Local `rand` Baseline

The local Rust `rand` checkout exposes weighted slice choice workflows centered
on reference output. Alea's reusable `WeightedChoice(T, Weight)` already provides
weighted pointer iterators through `iter*`; explicit `ptrIter*` aliases make that
reference-oriented path more discoverable while retaining Zig-native
pointer/value/index output families.

## API Added

`src/seq.zig` adds pointer iterator aliases to `WeightedChoice(T, Weight)`:

- `WeightedChoice(T, Weight).ptrIter`
- `WeightedChoice(T, Weight).ptrIterFrom`
- `WeightedChoice(T, Weight).ptrIterChecked`
- `WeightedChoice(T, Weight).ptrIterCheckedFrom`

The aliases delegate to existing `iter*` behavior. `docs/api-reference.md` lists
the new public symbols. Existing APIs are unchanged.

Deterministic behavior is explicit:

- `ptrIterFrom` preserves `iterFrom` scalar and fill stream shape.
- Checked pointer iterator aliases do not introduce new failure modes because
  successful `WeightedChoice` construction already validates the item slice and
  weights.

## Adoption and Documentation

- Focused weighted-choice tests compare `ptrIterFrom` and `iterFrom` scalar draws
  and fill output/stream shape.
- Tests compare checked and unchecked pointer iterator aliases for stream parity.
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
roadmapcheck ok
examplecheck ok
apicheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M728 is closed for the current bar: reusable `WeightedChoice` now has explicit
pointer iterator aliases and checked aliases that preserve existing weighted
pointer iterator stream shape. This is reliability/ergonomics work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
