# S4-M784 Iterator Fill Exact-Long End-Probe Avoidance

## Gap

S4-M783 tightened fixed-size unweighted iterator arrays for exact-long sources.
Caller-owned unweighted iterator fills had the same remaining issue: exact-long
sources preserved reservoir stream shape but still required an extra trailing
null probe to discover the end of the iterator.

## Local `rand` Baseline

Rust iterator sampling uses iterator length information where available. Alea's
caller-owned iterator fill helpers can use exact remaining to stop after the
reported count while preserving the stable reservoir stream shape for exact-long
sources.

## Implementation

- `src/seq.zig` bounds `sampleIteratorIntoFrom` and checked fill continuation by
  exact remaining when available.
- `src/root.zig` adds a shared `rootSampleIteratorIntoFrom` core for optional and
  checked root fills, using exact remaining to avoid trailing null probes on
  exact-long sources while preserving entropy/stream behavior.
- Focused tests compare exact-size and generic iterators for stream-shape parity
  and prove exact-size iterators are read exactly `remaining` times instead of
  probing one more time.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "exact-long iterator fills avoid trailing probe"
1/2 seq.test.exact-long iterator fills avoid trailing probe...OK
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
toolingcheck ok
readmecheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M784 is closed for the current bar: seq/root caller-owned unweighted iterator
fills now avoid trailing end probes for exact-long sources while preserving
reservoir stream shape. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
