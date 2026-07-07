# S4-M780 Weighted Iterator Array Exact Metadata Reuse

## Gap

S4-M775 made fixed-size weighted iterator arrays use exact remaining information
for exact-count sources, but the public optional/checked wrappers and private
candidate-array core each queried exact remaining metadata. Iterators with
observable or non-trivial `remaining`, `len`, or exact `sizeHint` methods could
therefore be probed twice before sampling.

## Local `rand` Baseline

The local Rust weighted sampling path (`IndexedRandom::sample_weighted` in
`src/seq/slice.rs`, backed by `index::sample_weighted` in `src/seq/index.rs`)
works from slice length and weight callbacks. Alea's iterator-specific helpers
can expose a stronger Zig-native behavior for exact-size iterators: query exact
remaining once at the API boundary, reuse the metadata in the candidate core, and
still preserve exact-count no-key/no-entropy sampling behavior.

## Implementation

- `src/seq.zig` caches `iteratorExactRemaining` in
  `sampleIteratorWeightedArrayFrom` and `sampleIteratorWeightedArrayCheckedFrom`,
  then passes it to `sampleIteratorWeightedCandidateArrayFrom`.
- `src/root.zig` mirrors the cached metadata flow for root
  `sampleIteratorWeightedArray` / checked variant and
  `rootSampleIteratorWeightedCandidateArray`.
- Focused tests count `remaining` calls on optional, checked, zero-weight, and
  invalid exact-count paths while keeping the previous exact read counts and
  no-entropy stream behavior.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "exact-count weighted iterator arrays avoid key sampling"
1/2 seq.test.exact-count weighted iterator arrays avoid key sampling...OK
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
roadmapcheck ok
examplecheck ok
apicheck ok
toolingcheck ok
```

## Result

S4-M780 is closed for the current bar: seq/root fixed-size weighted iterator
arrays now reuse exact remaining metadata across wrapper/core boundaries, avoiding
duplicate size-hint/remaining probes while preserving exact-count semantics. This
is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
