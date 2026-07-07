# S4-M781 Weighted Iterator Sample Exact Metadata Reuse

## Gap

S4-M776 made allocation-returning weighted iterator samples exploit exact-cover
sources, but checked sequence samples and root weighted sample wrappers could
still query exact remaining metadata in both the public wrapper and the weighted
sample core. Iterators with observable or non-trivial `remaining`, `len`, or
exact `sizeHint` methods were therefore probed twice before sampling.

## Local `rand` Baseline

The local Rust weighted sampling path (`IndexedRandom::sample_weighted` in
`src/seq/slice.rs`, backed by `index::sample_weighted` in `src/seq/index.rs`)
uses slice length directly. Alea's iterator-specific allocation helpers can offer
a stronger exact-size iterator behavior: query exact remaining once at the API
boundary or core entry, reuse that metadata for prevalidation and capacity, and
still preserve exact-cover heap/key/entropy avoidance.

## Implementation

- `src/seq.zig` caches `iteratorExactRemaining` in
  `sampleIteratorWeightedCheckedFrom` and reuses it for queue capacity instead of
  probing a second time.
- `src/root.zig` caches exact remaining in `sampleIteratorWeighted` /
  `sampleIteratorWeightedChecked` and passes it into `rootSampleIteratorWeightedAlloc`.
- Focused tests count `remaining` calls on optional/checked all-positive and
  sparse exact-cover sample paths while preserving previous exact read counts,
  no-heap/no-key behavior, and no-entropy stream behavior.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "exact-cover weighted iterator samples avoid heap setup"
1/2 seq.test.exact-cover weighted iterator samples avoid heap setup...OK
2/2 root.test_0...OK
All 2 tests passed.
```

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
readmecheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M781 is closed for the current bar: seq/root allocation-returning weighted
iterator samples now reuse exact remaining metadata across wrapper/core
boundaries, avoiding duplicate size-hint/remaining probes while preserving
exact-cover semantics. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
