# S4-M812 Choice Index Iterators Direct Scalar Sampling

## Gap

S4-M809 and S4-M811 optimized reusable `Choice` bulk index fills. The scalar
`Choice.IndexIterator.nextValue` and `Choice.U32IndexIterator.nextValue` paths
still routed each item through `sampleIndexFrom` / `sampleIndexU32From`, adding a
wrapper call for every iterator element.

## Local `rand` Baseline

Rust choice iterators are uniform index streams over a fixed slice length. Alea's
reusable `Choice` index iterators should likewise generate scalar indexes
directly from the cached choice length while preserving singleton no-consumption
and compact-width construction checks.

## Implementation

- `src/seq.zig` updates `Choice.IndexIterator.nextValue` to read `items.len` once
  and return `0` for singleton choices or `Rng.uintLessThanFrom` for multi-item
  choices.
- `src/seq.zig` updates `Choice.U32IndexIterator.nextValue` with the same direct
  scalar sampling policy after construction has already checked compact width.
- Focused tests compare `next()` outputs with `Rng.chooseIndexFrom` and
  `Rng.chooseIndexU32From` under identical seeds, proving stream shape stays
  aligned.

## Validation

Focused sequence test:

```text
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
examplecheck ok
roadmapcheck ok
apicheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M812 is closed for the current bar: reusable `Choice` usize/u32 index iterator
scalar `next()` calls now avoid per-item sample wrapper calls and generate
uniform indexes directly from choice length while preserving stream shape. This
is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
