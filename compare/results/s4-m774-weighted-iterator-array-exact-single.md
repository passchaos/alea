# S4-M774 Weighted Iterator Array Exact-Single Key Avoidance

## Gap

S4-M771 through S4-M773 handled exact-single weighted iterator choices,
allocation-returning samples, and caller-owned fills. Fixed-size weighted
iterator arrays still routed exact-single `N == 1` sources through the generic
candidate-array path, which needed an extra end-of-iterator probe before it could
return the one pending item.

## Local `rand` Baseline

The local Rust `rand` weighted slice sampling path (`src/seq/slice.rs` via
`src/seq/index.rs`) validates weights while sampling without replacement. Alea's
iterator-specific fixed-array helpers can use exact remaining information that
Rust's slice path does not expose as an iterator API: when exactly one weighted
entry remains and `N == 1`, Alea can validate that entry and return it without
key sampling, entropy, random-stream use, or a trailing null probe.

## Implementation

- `src/seq.zig` handles exact remaining of one in
  `sampleIteratorWeightedCandidateArrayFrom` for `N == 1`.
- `src/root.zig` handles exact remaining of one in
  `rootSampleIteratorWeightedCandidateArray` for `N == 1`.
- Positive weights return the single item; zero weights return `null` for the
  optional array helper and `error.InvalidParameter` for checked arrays; invalid
  weights still return `error.InvalidWeight`.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "single exact weighted iterator arrays avoid key sampling"
1/2 seq.test.single exact weighted iterator arrays avoid key sampling...OK
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
roadmapcheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M774 is closed for the current bar: seq/root fixed-size weighted iterator
arrays now resolve exact-single `N == 1` sources without key sampling, extra
probes, entropy, or random-stream use. This is reliability/ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
