# S4-M722 Distribution Choose Checked Iterator Aliases

## Gap

Distribution-layer `Choose` now has value, pointer, and index iterators. The
non-u32 iterator families still lacked checked aliases, making iterator APIs less
consistent with checked value/index/pointer output helpers.

Distribution-layer `Choose` should provide checked iterator aliases that preserve
stream shape while improving API discoverability. For value iterators, checked
aliases should provide an explicit empty-type error path.

## Local `rand` Baseline

The local Rust `rand` checkout exposes iterator-oriented repeated choice
workflows. Alea's Zig-native API consistently uses checked suffixes across many
fallible/discoverable helper families; distribution-layer `Choose` now matches
that pattern for repeated iterators.

## API Added

`src/distributions.zig` adds checked iterator aliases to `Choose(T)`:

- `Choose(T).valueIterChecked`
- `Choose(T).valueIterCheckedFrom`
- `Choose(T).ptrIterChecked`
- `Choose(T).ptrIterCheckedFrom`
- `Choose(T).indexIterChecked`
- `Choose(T).indexIterCheckedFrom`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Checked pointer and index iterator aliases preserve the stream shape of their
  unchecked counterparts.
- Checked value iterators return `error.EmptyRange` for empty enum-containing
  value types before random-stream use or value copying.

## Adoption and Documentation

- Focused distribution tests compare checked and unchecked value/pointer/index
  iterator scalar draws for stream-shape parity, and cover checked value iterator
  empty-type failure with zero stream consumption.
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
examplecheck ok
roadmapcheck ok
toolingcheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M722 is closed for the current bar: distribution-layer `Choose` now has
checked aliases for value, pointer, and usize index iterators. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
