# S4-M777 Weighted Iterator Fill Exact-Cover Key Avoidance

## Gap

S4-M776 handled allocation-returning weighted iterator samples when exact
remaining entries are fully covered by the requested amount. Caller-owned
weighted iterator fills had the same exact-cover opportunity: if exact remaining
is no larger than the output buffer, all positive-weight remaining entries are in
the result, so weighted keys, entropy, and the trailing null probe are
unnecessary.

## Local `rand` Baseline

The local Rust weighted sampling path (`IndexedRandom::sample_weighted` in
`src/seq/slice.rs`, backed by `index::sample_weighted` in `src/seq/index.rs`)
returns fewer than requested when there are insufficient non-zero weights and
validates inspected weights. Alea's caller-owned iterator fill helpers can
additionally use exact remaining information: exact-cover sources are validated
with exactly the known reads, the positive-weight subset is written directly to
the caller's buffer, and checked variants preserve the requirement that enough
positive entries exist.

## Implementation

- `src/seq.zig` adds `sampleIteratorWeightedIntoExactCover` and routes
  `sampleIteratorWeightedIntoFrom` / checked variant through it for exact-cover
  sources.
- `src/root.zig` adds `rootSampleIteratorWeightedIntoExactCover` and routes root
  weighted iterator fills through it for exact-cover sources.
- All-positive exact-cover sources write exactly the known entries. Sparse
  unchecked exact-cover sources write the positive-weight subset. Checked sparse
  sources return `error.InvalidParameter`. Invalid weights still return
  `error.InvalidWeight`.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "exact-cover weighted iterator fills avoid key sampling"
1/2 seq.test.exact-cover weighted iterator fills avoid key sampling...OK
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
readmecheck ok
apicheck ok
toolingcheck ok
```

## Result

S4-M777 is closed for the current bar: seq/root caller-owned weighted iterator
fills now resolve exact-cover sources without key sampling, extra probes,
entropy, or random-stream use while preserving sparse positive and checked error
semantics. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
