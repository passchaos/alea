# S4-M791 Sampled Iterator Fill Index-Buffer Reuse

## Gap

`SampledValueIterator`, `SampledPtrIterator`, and `SampledMutPtrIterator` own an
`IndexVec.IntoIterator`. Their `fill` methods previously computed `remaining()`
and then called `next()` once per output slot, which repeatedly traversed the
value/pointer iterator wrapper even though the underlying index iterator already
has a bulk `fill` method.

## Local `rand` Baseline

Rust sampled iterator APIs expose collected sampled indices as iterators over
values. Alea can keep the same owned-sample semantics while using its Zig-native
`IndexVec` bulk fill path to reduce per-slot overhead in caller-owned fill
workflows.

## Implementation

- `src/seq.zig` updates `SampledValueIterator.fill` to bulk-fill sampled indices
  into a stack buffer and then map them to values.
- `src/seq.zig` applies the same index-buffer fill path to
  `SampledPtrIterator.fill` and `SampledMutPtrIterator.fill`.
- Existing sampled iterator fill tests cover value, const-pointer, and
  mutable-pointer fill behavior; a focused value test also covers a fill larger
  than the internal 64-index chunk.

## Validation

Focused sequence tests:

```text
$ zig test src/seq.zig --test-filter "sampleItemsIter owns sampled indices and streams values"
1/2 seq.test.sampleItemsIter owns sampled indices and streams values...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "samplePtrsIter owns sampled indices and streams pointers"
1/2 seq.test.samplePtrsIter owns sampled indices and streams pointers...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "sampleMutPtrsIter owns sampled indices and streams mutable pointers"
1/2 seq.test.sampleMutPtrsIter owns sampled indices and streams mutable pointers...OK
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

S4-M791 is closed for the current bar: sampled value/const-pointer/mutable-pointer
iterator fills now reuse the owned `IndexVec` iterator's bulk fill path while
preserving output behavior. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
