# S4-M813 Distribution Choose Index Iterators Direct Scalar Sampling

## Gap

S4-M808 and S4-M810 optimized distribution-layer `Choose` bulk index fills. The
scalar `Choose.IndexIterator.nextValue` and `Choose.U32IndexIterator.nextValue`
paths still routed each item through `sampleIndexFrom` / `sampleIndexU32From`,
adding a wrapper call for every iterator element.

## Local `rand` Baseline

Rust choice iterators are uniform index streams over a fixed slice length. Alea's
distribution-layer `Choose` index iterators should likewise generate scalar
indexes directly from cached choice length while preserving singleton
no-consumption and compact-width construction checks.

## Implementation

- `src/distributions.zig` updates `Choose.IndexIterator.nextValue` to read
  `items.len` once and return `0` for singleton choices or
  `Rng.uintLessThanFrom` for multi-item choices.
- `src/distributions.zig` updates `Choose.U32IndexIterator.nextValue` with the
  same direct scalar sampling policy after construction has already checked
  compact width.
- Focused tests compare `next()` outputs with `Rng.chooseIndexFrom` and
  `Rng.chooseIndexU32From` under identical seeds, proving stream shape stays
  aligned.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "distribution Choose sampler mirrors slice choices"
1/2 distributions.test.distribution Choose sampler mirrors slice choices...OK
2/2 root.test_0...OK
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

S4-M813 is closed for the current bar: distribution-layer `Choose` usize/u32
index iterator scalar `next()` calls now avoid per-item sample wrapper calls and
generate uniform indexes directly from choice length while preserving stream
shape. This is reliability/ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
