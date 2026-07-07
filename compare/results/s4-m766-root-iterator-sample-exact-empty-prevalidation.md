# S4-M766 Root Iterator Sample Exact-Empty Prevalidation

## Gap

S4-M762 tightened seq allocation-returning iterator samples and root weighted
iterator samples for exact-empty sources. Root unweighted `sampleIterator` already
used exact remaining information to reduce initial capacity, but still called the
iterator once before returning an empty result.

## Local `rand` Baseline

The local Rust iterator sampling APIs use exact iterator size information where
available. Alea's root explicit-I/O helper should likewise avoid unnecessary
iterator reads, allocation, entropy, and random-stream use for exact-empty
sources.

## Implementation

`src/root.zig` now prevalidates exact-empty sources in `sampleIterator` before
constructing the reservoir or reading the iterator.

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
apicheck ok
examplecheck ok
roadmapcheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M766 is closed for the current bar: root `sampleIterator` now returns an empty
output for exact-empty sources before reservoir allocation, iterator consumption,
entropy, or random-stream use. This is reliability/validation work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
