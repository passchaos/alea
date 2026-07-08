# S4-M793 IndexVec Mapped Into Switch-Once Loops

## Gap

S4-M792 improved IndexVec mapped iterator fills, but caller-owned mapping helpers
(`valuesInto`, `ptrsInto`, and `mutPtrsInto`) still called `IndexVec.at()` for
every output slot. Since `IndexVec` is a tagged union, this repeated the backing
representation dispatch per slot.

## Local `rand` Baseline

Rust indexed sample mappings iterate over concrete index storage and map to
values/references. Alea's IndexVec can mirror this more directly by switching on
its compact/native backing once and then mapping through the concrete index
slice.

## Implementation

- `src/seq.zig` updates `IndexVec.valuesInto` to switch once on `.u32`/`.usize`
  backing and map directly to values.
- `src/seq.zig` applies the same representation-specific loop to
  `IndexVec.ptrsInto` and `IndexVec.mutPtrsInto`.
- Existing focused IndexVec mapping tests cover compact and native value/pointer
  mappings, mutable pointer mappings, and validation failures.

## Validation

Focused sequence tests:

```text
$ zig test src/seq.zig --test-filter "index vec maps sampled indexes to slice items"
1/1 seq.test.index vec maps sampled indexes to slice items...OK
All 1 tests passed.
```

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

S4-M793 is closed for the current bar: IndexVec caller-owned value/pointer mapping
helpers now switch once on compact/native backing and map outputs directly. This
is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
