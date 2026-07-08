# S4-M788 Weighted Iterator Fill Exact-Long End-Probe Avoidance

## Gap

S4-M787 tightened fixed-size weighted iterator arrays for exact-long sources.
Caller-owned weighted iterator fills had the same trailing-probe issue: exact-long
sources preserved weighted-key stream shape but still required one extra null
probe to discover the end of the iterator.

## Local `rand` Baseline

The local Rust weighted sampling path (`IndexedRandom::sample_weighted` in
`src/seq/slice.rs`, backed by `index::sample_weighted` in `src/seq/index.rs`)
works from known slice length. Alea's caller-owned weighted iterator fill helpers
can use exact remaining to stop after the reported count while preserving
weighted-key stream shape for exact-long sources.

## Implementation

- `src/seq.zig` threads exact remaining metadata into
  `sampleIteratorWeightedIntoCore` and bounds exact-long candidate scanning by
  known remaining.
- `src/root.zig` mirrors bounded exact-long scanning in
  `rootSampleIteratorWeightedInto`.
- Focused tests compare exact-size and generic iterators for stream-shape parity
  and prove exact-size iterators are read exactly `remaining` times instead of
  probing one more time; root tests verify exact read counts under failing
  entropy.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "exact-long weighted iterator fills avoid trailing probe"
1/2 seq.test.exact-long weighted iterator fills avoid trailing probe...OK
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
apicheck ok
toolingcheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M788 is closed for the current bar: seq/root caller-owned weighted iterator
fills now avoid trailing end probes for exact-long sources while preserving
weighted-key stream shape. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
