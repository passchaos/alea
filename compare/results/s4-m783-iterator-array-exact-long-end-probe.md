# S4-M783 Iterator Array Exact-Long End-Probe Avoidance

## Gap

Earlier iterator sampling milestones tightened exact-empty, exact-short, and
exact-count paths. Fixed-size unweighted iterator arrays still used generic
reservoir iteration after the initial `N` items when exact remaining was larger
than `N`, which preserved stream shape but required an extra trailing null probe
to discover the end.

## Local `rand` Baseline

Rust `IteratorRandom::choose_multiple_array` / fixed-size iterator sampling uses
iterator length information where available. Alea's fixed-size iterator arrays
can use exact remaining to stop after the reported count while preserving the
stable reservoir stream shape for exact-long sources.

## Implementation

- `src/seq.zig` bounds `sampleIteratorArrayFrom` reservoir continuation by exact
  remaining when available, and routes checked arrays through the same optional
  array core to reuse exact metadata.
- `src/root.zig` adds a shared `rootSampleIteratorArrayFrom` core for optional
  and checked root arrays, using exact remaining to avoid trailing null probes on
  exact-long sources while preserving entropy/stream behavior.
- Focused tests compare exact-size and generic iterators for stream-shape parity
  and prove exact-size iterators are read exactly `remaining` times instead of
  probing one more time.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "exact-long iterator arrays avoid trailing probe"
1/2 seq.test.exact-long iterator arrays avoid trailing probe...OK
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
roadmapcheck ok
readmecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M783 is closed for the current bar: seq/root fixed-size unweighted iterator
arrays now avoid trailing end probes for exact-long sources while preserving
reservoir stream shape. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
