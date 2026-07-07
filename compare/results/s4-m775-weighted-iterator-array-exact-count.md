# S4-M775 Weighted Iterator Array Exact-Count Key Avoidance

## Gap

S4-M774 handled the exact-single `N == 1` fixed-size weighted iterator-array
case. More generally, when an exact-size iterator reports that its remaining
entry count equals the requested fixed array size, every remaining entry must be
selected if all remaining weights are positive. The generic weighted candidate
path previously still assigned random keys, requested entropy, and probed once
past the exact count.

## Local `rand` Baseline

The local Rust weighted sampling path (`IndexedRandom::sample_weighted` in
`src/seq/slice.rs`, backed by `index::sample_weighted` in `src/seq/index.rs`)
returns up to the requested amount of positive-weight items and validates every
weight it inspects. Alea's iterator-specific fixed-array helpers can use exact
remaining information that Rust's slice path does not expose as an iterator API:
when exact remaining equals `N`, Alea can validate exactly those entries and
return them without weighted-key generation or entropy, while zero weights still
make the optional fixed array unavailable and make checked arrays fail.

## Implementation

- `src/seq.zig` generalizes `sampleIteratorWeightedCandidateArrayFrom` exact
  remaining handling from exact-single to exact-count.
- `src/root.zig` mirrors the exact-count path in
  `rootSampleIteratorWeightedCandidateArray`.
- All-positive exact-count sources return the remaining items after exactly `N`
  reads. Zero-weight entries return `null` for optional arrays and
  `error.InvalidParameter` for checked arrays. Invalid weights still return
  `error.InvalidWeight` after validating the exact remaining entries.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "exact-count weighted iterator arrays avoid key sampling"
1/2 seq.test.exact-count weighted iterator arrays avoid key sampling...OK
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

S4-M775 is closed for the current bar: seq/root fixed-size weighted iterator
arrays now resolve all-positive exact-count sources without key sampling, extra
probes, entropy, or random-stream use, while preserving zero-weight and invalid
weight semantics. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
