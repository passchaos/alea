# S4-M883 WeightedChoice Pointer Iterator Direct Table Mapping

## Gap

Reusable `WeightedChoice.Iterator.nextValue` still routed every pointer output
through `WeightedChoice.sampleFrom`, adding a wrapper call before sampling the
underlying alias table and mapping into the item slice.

## Local `rand` Baseline

Local `rand` weighted iterator-style choices repeatedly sample a weighted index
and map it to the chosen item/reference. Alea's `WeightedChoice` already stores
both the item slice and the `AliasTable`, so pointer iterators can sample the
underlying table directly and map to `items[index]` while preserving the same
stream as repeated `WeightedChoice.sampleFrom` calls.

## Implementation

- `src/seq.zig` updates `WeightedChoice.Iterator.nextValue` to sample
  `choice.table` directly and return `&choice.items[index]` instead of calling
  `choice.sampleFrom`.
- Focused tests compare iterator scalar output with direct table sampling under
  identical seeds; existing focused tests still cover iterator fill aliases,
  checked iterator forms, and single-positive no-consume behavior.

## Validation

Focused sequence test:

```text
$ zig test src/seq.zig --test-filter "weighted choice iterator streams repeated const pointers"
1/4 seq.test.weighted choice iterator streams repeated const pointers...OK
2/4 seq.test.accessor weighted choice iterator streams repeated const pointers...OK
3/4 seq.test.index-weighted choice iterator streams repeated const pointers...OK
4/4 root.test_0...OK
All 4 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
apicheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M883 is closed for the current bar: reusable `WeightedChoice.Iterator.nextValue`
now avoids per-output `WeightedChoice.sampleFrom` wrapper calls while preserving
stream shape and existing iterator behavior. This is reliability/ergonomics work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
