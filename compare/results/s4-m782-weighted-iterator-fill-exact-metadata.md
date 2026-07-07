# S4-M782 Weighted Iterator Fill Exact Metadata Reuse

## Gap

S4-M777 made caller-owned weighted iterator fills exploit exact-cover sources,
but root public fill wrappers and the private fill core still each queried exact
remaining metadata. Iterators with observable or non-trivial `remaining`, `len`,
or exact `sizeHint` methods were therefore probed twice before filling.

## Local `rand` Baseline

The local Rust weighted sampling path (`IndexedRandom::sample_weighted` in
`src/seq/slice.rs`, backed by `index::sample_weighted` in `src/seq/index.rs`)
uses slice length directly. Alea's root iterator-specific fill helpers can offer
a stronger exact-size iterator behavior: query exact remaining once at the public
API boundary, reuse that metadata inside the fill core, and still preserve
exact-cover no-key/no-entropy fill behavior.

## Implementation

- `src/root.zig` caches exact remaining in `sampleIteratorWeightedInto` and
  `sampleIteratorWeightedIntoChecked`.
- `src/root.zig` passes cached metadata into `rootSampleIteratorWeightedInto`.
- Focused root tests count `remaining` calls on optional/checked all-positive and
  sparse exact-cover fill paths while preserving previous exact read counts and
  no-key/no-entropy behavior.

## Validation

Focused root test:

```text
$ zig test src/root.zig --test-filter "root random helpers validate deterministic cases before entropy"
1/2 root.test_0...OK
2/2 root.test.root random helpers validate deterministic cases before entropy...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M782 is closed for the current bar: root caller-owned weighted iterator fills
now reuse exact remaining metadata across wrapper/core boundaries, avoiding
duplicate size-hint/remaining probes while preserving exact-cover semantics. This
is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
