# S4-M785 Iterator Sample Exact-Long End-Probe Avoidance

## Gap

S4-M783 and S4-M784 tightened fixed-size arrays and caller-owned fills for
exact-long unweighted iterators. Allocation-returning unweighted iterator samples
still preserved reservoir stream shape but required an extra trailing null probe
to discover the end when exact remaining was larger than the requested amount.

## Local `rand` Baseline

Rust iterator sampling uses iterator length information where available. Alea's
allocation-returning iterator sample helpers can use exact remaining to stop
after the reported count while preserving the stable reservoir stream shape for
exact-long sources.

## Implementation

- `src/seq.zig` bounds exact-long `sampleIteratorFrom` and
  `sampleIteratorCheckedFrom` reservoir continuation by known remaining.
- `src/root.zig` adds a shared `rootSampleIteratorFrom` core for optional and
  checked root allocation-returning samples, using exact remaining to avoid
  trailing null probes on exact-long sources while preserving entropy/stream
  behavior.
- Focused tests compare exact-size and generic iterators for stream-shape parity
  and prove exact-size iterators are read exactly `remaining` times instead of
  probing one more time.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "exact-long iterator samples avoid trailing probe"
1/2 seq.test.exact-long iterator samples avoid trailing probe...OK
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
apicheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M785 is closed for the current bar: seq/root allocation-returning unweighted
iterator samples now avoid trailing end probes for exact-long sources while
preserving reservoir stream shape. This is reliability/ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
