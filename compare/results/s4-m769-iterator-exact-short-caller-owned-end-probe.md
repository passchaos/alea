# S4-M769 Iterator Exact-Short Caller-Owned End-Probe Avoidance

## Gap

S4-M768 avoided extra end-of-iterator probes for allocation-returning unweighted
iterator samples. Caller-owned unweighted iterator fills could use the same exact
remaining information: when the source is known to have fewer items than the
output buffer, read exactly those items and return the partial count without an
extra `next()` call to observe `null`.

## Local `rand` Baseline

The local Rust iterator sampling APIs use exact iterator size information where
available. Alea can use the same information to avoid unnecessary end probes in
caller-owned fills.

## Implementation

- `src/seq.zig` uses exact remaining counts as the fill target in
  `sampleIteratorIntoFrom` / `sampleIteratorFillFrom`.
- `src/root.zig` applies the same fill-target logic in root `sampleIteratorInto`.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "exact-short iterator fills avoid end probe"
1/2 seq.test.exact-short iterator fills avoid end probe...OK
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
readmecheck ok
roadmapcheck ok
apicheck ok
toolingcheck ok
```

## Result

S4-M769 is closed for the current bar: seq/root caller-owned unweighted iterator
fills now avoid extra end-of-iterator probes for exact-short sources. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
