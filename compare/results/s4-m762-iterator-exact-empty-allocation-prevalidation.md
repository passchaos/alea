# S4-M762 Iterator Exact-Empty Allocation Prevalidation

## Gap

S4-M760 and S4-M761 tightened exact-short checked and optional fixed-array
iterator paths. Allocation-returning unchecked iterator samples can also use exact
`remaining` / `sizeHint` information when the source is known to be empty: for a
non-zero requested amount, they can return an empty result without building a
reservoir/heap, reading the iterator, or drawing randomness.

## Local `rand` Baseline

The local Rust iterator sampling APIs use exact iterator information where
available. Alea's Zig-native helpers can likewise avoid unnecessary allocation
and entropy setup for exact-empty sources.

## Implementation

- `src/seq.zig` prevalidates exact-empty sources in `sampleIteratorFrom`.
- `src/seq.zig` prevalidates exact-empty sources in `sampleIteratorWeightedFrom`.
- `src/root.zig` prevalidates exact-empty sources in `sampleIteratorWeighted`
  before delegating to the weighted reservoir helper.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "empty exact iterator samples avoid reservoir allocation"
1/2 seq.test.empty exact iterator samples avoid reservoir allocation...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "empty exact weighted iterator samples avoid heap allocation"
1/2 seq.test.empty exact weighted iterator samples avoid heap allocation...OK
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
readmecheck ok
apicheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M762 is closed for the current bar: seq/root allocation-returning iterator
sampling helpers now return empty outputs for exact-empty sources before
reservoir/heap allocation, iterator consumption, entropy, or random-stream use.
This is reliability/validation work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
