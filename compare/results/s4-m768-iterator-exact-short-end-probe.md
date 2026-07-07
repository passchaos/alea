# S4-M768 Iterator Exact-Short End-Probe Avoidance

## Gap

S4-M767 capped allocation capacity for exact-short iterator samples. The
unweighted allocation-returning helpers could also avoid one more unnecessary
operation: after exact remaining says the source has fewer items than requested,
the helper can read exactly those remaining items and return without an extra
`next()` call to observe `null`.

## Local `rand` Baseline

The local Rust iterator sampling APIs use exact iterator size information where
available. Alea can use the same information to avoid unnecessary end probes for
well-described iterators.

## Implementation

- `src/seq.zig` uses exact remaining counts as the fill target in
  `sampleIteratorFrom` and returns immediately when exact remaining is not larger
  than the requested amount.
- `src/root.zig` applies the same fill-target logic in root `sampleIterator`.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "exact-short iterator samples cap reservoir allocation"
1/2 seq.test.exact-short iterator samples cap reservoir allocation...OK
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
roadmapcheck ok
toolingcheck ok
readmecheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M768 is closed for the current bar: seq/root allocation-returning unweighted
iterator samples now avoid extra end-of-iterator probes for exact-short sources.
This is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
