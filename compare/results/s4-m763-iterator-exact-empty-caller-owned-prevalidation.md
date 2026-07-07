# S4-M763 Iterator Exact-Empty Caller-Owned Prevalidation

## Gap

S4-M762 tightened allocation-returning iterator helpers for exact-empty sources.
Caller-owned iterator sampling helpers can use the same exact `remaining` /
`sizeHint` information: when the source is known empty and the output buffer is
non-empty, unchecked helpers can return zero before reading the iterator or using
randomness/entropy.

## Local `rand` Baseline

The local Rust iterator sampling APIs use exact iterator size information where
available. Alea's caller-owned iterator helpers can likewise avoid unnecessary
iterator reads and entropy setup for exact-empty sources.

## Implementation

- `src/seq.zig` prevalidates exact-empty sources in `sampleIteratorIntoFrom` and
  `sampleIteratorFillFrom`.
- `src/seq.zig` prevalidates exact-empty sources in
  `sampleIteratorWeightedIntoFrom`.
- `src/root.zig` prevalidates exact-empty sources in `sampleIteratorInto` and
  `sampleIteratorWeightedInto`.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "empty exact iterator fills avoid source consumption"
1/2 seq.test.empty exact iterator fills avoid source consumption...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "empty exact weighted iterator fills avoid source consumption"
1/2 seq.test.empty exact weighted iterator fills avoid source consumption...OK
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
apicheck ok
readmecheck ok
roadmapcheck ok
examplecheck ok
```

## Result

S4-M763 is closed for the current bar: seq/root caller-owned iterator sampling
helpers now return zero for exact-empty sources before iterator consumption,
entropy, or random-stream use. This is reliability/validation work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
