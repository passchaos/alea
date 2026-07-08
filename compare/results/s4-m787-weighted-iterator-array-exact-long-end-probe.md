# S4-M787 Weighted Iterator Array Exact-Long End-Probe Avoidance

## Gap

S4-M783 tightened unweighted fixed-size iterator arrays for exact-long sources.
Fixed-size weighted iterator arrays had the same trailing-probe issue in their
generic candidate scan: exact-long sources preserved weighted-key stream shape but
still required one extra null probe to discover the end.

## Local `rand` Baseline

The local Rust weighted sampling path (`IndexedRandom::sample_weighted` in
`src/seq/slice.rs`, backed by `index::sample_weighted` in `src/seq/index.rs`)
works from known slice length. Alea's iterator-specific fixed-size weighted array
helpers can use exact remaining to stop after the reported count while preserving
weighted-key stream shape for exact-long sources.

## Implementation

- `src/seq.zig` bounds `sampleIteratorWeightedCandidateArrayFrom` candidate
  scanning by cached exact remaining metadata when available.
- `src/root.zig` mirrors the bounded scan in
  `rootSampleIteratorWeightedCandidateArray`.
- Focused tests compare exact-size and generic iterators for stream-shape parity
  and prove exact-size iterators are read exactly `remaining` times instead of
  probing one more time; root tests verify exact read counts under failing
  entropy.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "exact-long weighted iterator arrays avoid trailing probe"
1/2 seq.test.exact-long weighted iterator arrays avoid trailing probe...OK
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
examplecheck ok
apicheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M787 is closed for the current bar: seq/root fixed-size weighted iterator
arrays now avoid trailing end probes for exact-long sources while preserving
weighted-key stream shape. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
