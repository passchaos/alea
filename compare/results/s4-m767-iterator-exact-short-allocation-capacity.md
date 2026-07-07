# S4-M767 Iterator Exact-Short Allocation Capacity

## Gap

Unchecked allocation-returning iterator samples may return fewer than requested
items when the source is shorter. When exact `remaining` / `sizeHint` proves the
source has fewer entries than requested, Alea can cap reservoir/heap capacity to
the known remaining count instead of allocating for the larger requested amount.

## Local `rand` Baseline

The local Rust iterator sampling APIs use exact iterator information where
available. Alea's allocation-returning helpers should use the same information to
avoid over-allocation for exact-short sources while still returning the partial
result expected from unchecked helpers.

## Implementation

- `src/seq.zig` caps `sampleIteratorFrom` reservoir capacity by exact remaining
  counts.
- `src/seq.zig` caps `sampleIteratorWeightedFrom` heap capacity by exact
  remaining counts.
- `src/root.zig` caps root weighted iterator pending/heap capacity by exact
  remaining counts.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "exact-short iterator samples cap reservoir allocation"
1/2 seq.test.exact-short iterator samples cap reservoir allocation...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "exact-short weighted iterator samples cap heap allocation"
1/2 seq.test.exact-short weighted iterator samples cap heap allocation...OK
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
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M767 is closed for the current bar: seq/root allocation-returning iterator
sampling helpers cap reservoir/heap capacity by exact remaining counts for
exact-short sources. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
