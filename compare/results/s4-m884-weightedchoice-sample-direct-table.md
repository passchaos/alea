# S4-M884 WeightedChoice Sample Direct Table Mapping

## Gap

Reusable `WeightedChoice.sampleFrom` still routed pointer sampling through
`WeightedChoice.sampleIndexFrom`, adding a wrapper call before sampling the
underlying alias table and mapping into the item slice.

## Local `rand` Baseline

Local `rand` weighted slice choice samples a weighted index and returns a
reference to the selected item. Alea's `WeightedChoice` already stores both the
item slice and the `AliasTable`, so scalar pointer sampling can sample the
underlying table directly and map to `items[index]` while preserving the same
stream as the existing index-sampling path.

## Implementation

- `src/seq.zig` updates `WeightedChoice.sampleFrom` to sample `self.table`
  directly and return `&self.items[index]` instead of routing through
  `sampleIndexFrom`.
- Focused tests compare `WeightedChoice.sampleFrom` output with direct table
  sampling under identical seeds; existing focused coverage still checks index,
  pointer/value fill, iterator, checked, and single-positive behavior.

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
examplecheck ok
toolingcheck ok
readmecheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M884 is closed for the current bar: reusable `WeightedChoice.sampleFrom` now
avoids the `sampleIndexFrom` wrapper call while preserving stream shape and
existing weighted-choice behavior. This is reliability/ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
