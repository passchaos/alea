# S4-M814 WeightedChoice Index Iterators Direct Table Sampling

## Gap

S4-M806 routed reusable `WeightedChoice` bulk index fills through the optimized
underlying `AliasTable` fill paths. The scalar `WeightedChoice.IndexIterator` and
`WeightedChoice.U32IndexIterator` paths still routed each item through
`WeightedChoice.sampleIndexFrom` / `sampleIndexU32From`, adding a wrapper call for
every iterator element.

## Local `rand` Baseline

Rust weighted choice iterators sample weighted indexes from the underlying
weighted-index distribution and map them to items or expose them as indexes.
Alea's reusable `WeightedChoice` wraps an `AliasTable`, so index iterators should
sample that table directly while preserving stream shape and compact-width
construction checks.

## Implementation

- `src/seq.zig` updates `WeightedChoice.IndexIterator.nextValue` to return
  `self.choice.table.sampleFrom(self.source)` directly.
- `src/seq.zig` updates `WeightedChoice.U32IndexIterator.nextValue` to use
  `self.choice.table.sampleU32CheckedFrom(self.source)` directly after iterator
  construction has already checked compact width.
- Focused tests compare iterator `next()` outputs with direct table samples under
  identical seeds, proving stream shape stays aligned.

## Validation

Focused sequence test:

```text
$ zig test src/seq.zig --test-filter "weighted choice sampler maps alias indexes to items"
1/2 seq.test.weighted choice sampler maps alias indexes to items...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
readmecheck ok
examplecheck ok
roadmapcheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M814 is closed for the current bar: reusable `WeightedChoice` usize/u32 index
iterator scalar `next()` calls now avoid per-item WeightedChoice sample wrapper
calls and sample the underlying AliasTable directly while preserving stream
shape. This is reliability/ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
