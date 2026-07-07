# S4-M776 Weighted Iterator Sample Exact-Cover Heap Avoidance

## Gap

S4-M775 handled fixed-size weighted iterator arrays when exact remaining equals
`N`. Allocation-returning weighted iterator samples had a related exact-cover
case: when the iterator reports that all remaining entries are covered by the
requested amount, every positive-weight remaining item is part of the output, so
the generic weighted heap/key path is unnecessary.

## Local `rand` Baseline

The local Rust weighted sampling path (`IndexedRandom::sample_weighted` in
`src/seq/slice.rs`, backed by `index::sample_weighted` in `src/seq/index.rs`)
returns fewer than the requested amount when insufficient non-zero weights are
available and validates inspected weights. Alea's iterator-specific allocation
helpers can additionally exploit exact remaining information: for exact-cover
sources, they validate exactly the known entries and return the positive-weight
subset without random weighted keys, heap setup, entropy, or a trailing null
probe. Checked variants preserve the stricter requirement that enough positive
weights exist.

## Implementation

- `src/seq.zig` adds `sampleIteratorWeightedExactCoverFrom` and routes
  `sampleIteratorWeightedFrom` / `sampleIteratorWeightedCheckedFrom` through it
  for exact-cover sources.
- `src/root.zig` adds `rootSampleIteratorWeightedExactCover` and routes root
  weighted iterator allocation through it for exact-cover sources.
- All-positive exact-cover sources allocate only the result buffer and return it
  in iterator order. Sparse exact-cover unchecked sources return a trimmed
  positive-weight subset. Checked sparse sources return `error.InvalidParameter`.
  Invalid weights still return `error.InvalidWeight`.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "exact-cover weighted iterator samples avoid heap setup"
1/2 seq.test.exact-cover weighted iterator samples avoid heap setup...OK
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
apicheck ok
roadmapcheck ok
readmecheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M776 is closed for the current bar: seq/root allocation-returning weighted
iterator samples now resolve exact-cover sources without weighted heap setup,
key sampling, extra probes, entropy, or random-stream use while preserving sparse
positive and checked error semantics. This is reliability/ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
