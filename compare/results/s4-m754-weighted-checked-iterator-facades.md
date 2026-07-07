# S4-M754 Weighted Checked Iterator Facades

## Gap

Checked iterator aliases existed for static `AliasTable` and dynamic
`WeightedTree` / `WeightedIntTree`, but focused coverage only constructed the
direct-source `iterCheckedFrom` forms. The facade `iterChecked(rng)` methods
returned through `iterCheckedFrom(rng)`, which has a different concrete iterator
payload type than the declared facade `Rng.SampleIterator(...)` return type.

The facade checked iterator constructors should compile directly and preserve the
same stream shape as direct-source checked iterators.

## Local `rand` Baseline

The local Rust weighted-index workflows are iterator-oriented. Alea exposes both
facade `Rng` and direct-source iterator constructors; checked aliases must work
in both forms without requiring users to switch to direct-source APIs.

## Fix

`src/distributions.zig` now constructs facade iterator payloads directly from:

- `AliasTable(Weight).iterChecked`;
- `WeightedTree(Weight).iterChecked`;
- `WeightedIntTree(Weight).iterChecked`.

Dynamic tree facade checked constructors still validate `isValid()` before
iterator construction.

## Coverage Added

Focused tests now compare facade checked iterators with direct-source checked
iterators for:

- static `AliasTable`;
- dynamic generic `WeightedTree`;
- dynamic integer `WeightedIntTree`.

The checks prove compilation of facade checked constructors and deterministic
stream-shape parity against the direct-source variants.

## Validation

Focused distribution tests:

```text
$ zig test src/distributions.zig --test-filter "alias table iterators produce repeated indices"
1/2 distributions.test.alias table iterators produce repeated indices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/distributions.zig --test-filter "weighted tree iterators produce repeated indices"
1/2 distributions.test.weighted tree iterators produce repeated indices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
roadmapcheck ok
readmecheck ok
examplecheck ok
apicheck ok
toolingcheck ok
```

## Result

S4-M754 is closed for the current bar: weighted checked iterator facade
constructors now return the correct iterator payloads and have focused
facade/direct stream-shape coverage. This is API-correctness/reliability work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
