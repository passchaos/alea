# S4-M792 IndexVec Mapped Iterator Fill Index-Buffer Reuse

## Gap

S4-M791 made owned sampled iterators bulk-fill sampled indices before mapping to
values or pointers. Non-owned `IndexVec` mapped iterators still used
`remaining()` plus per-slot `next()` calls, and the base `IndexVec.Iterator` /
`IntoIterator` fills also advanced through `next()` one slot at a time.

## Local `rand` Baseline

Rust indexed sample iterators map sampled indices to values or references. Alea
has Zig-native `IndexVec` iterators with an explicit caller-owned `fill` API; this
can copy index ranges directly and map them in chunks to reduce wrapper overhead
while preserving output semantics.

## Implementation

- `src/seq.zig` updates `IndexVec.Iterator.fill` and `IndexVec.IntoIterator.fill`
  to copy index ranges directly and advance once.
- `src/seq.zig` updates non-owned `IndexVec.ValueIterator.fill`, `PtrIterator.fill`,
  and `MutPtrIterator.fill` to bulk-fill indices in chunks before mapping to
  outputs.
- Focused tests cover base IndexVec fills plus mapped value/const-pointer/
  mutable-pointer fills; sampled iterator fill regression tests remain green.

## Validation

Focused sequence tests:

```text
$ zig test src/seq.zig --test-filter "index vec iterators fill caller-owned buffers"
1/1 seq.test.index vec iterators fill caller-owned buffers...OK
All 1 tests passed.
```

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
readmecheck ok
examplecheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M792 is closed for the current bar: IndexVec base and mapped iterator fills now
reuse index-buffer fills instead of per-slot `next()` calls while preserving
output behavior. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
