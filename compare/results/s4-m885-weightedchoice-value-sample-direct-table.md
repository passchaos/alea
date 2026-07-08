# S4-M885 WeightedChoice Value Sample Direct Table Mapping

## Gap

Reusable `WeightedChoice.sampleValueFrom` still routed scalar value sampling
through `WeightedChoice.sampleFrom`, adding a wrapper call before sampling the
underlying alias table and copying the selected item.

## Local `rand` Baseline

Local `rand` weighted slice choice samples a weighted index and returns/copies the
selected item/reference. Alea's `WeightedChoice` stores both the item slice and
the `AliasTable`, so scalar value sampling can sample the underlying table
directly and copy `items[index]` while preserving the same stream as the existing
pointer/index paths.

## Implementation

- `src/seq.zig` updates `WeightedChoice.sampleValueFrom` to sample `self.table`
  directly and return `self.items[index]` instead of routing through
  `sampleFrom`.
- Focused tests compare `WeightedChoice.sampleValueFrom` output with direct table
  sampling under identical seeds; existing focused coverage still checks pointer,
  index, fill, iterator, checked, and single-positive behavior.

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
roadmapcheck ok
apicheck ok
examplecheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M885 is closed for the current bar: reusable `WeightedChoice.sampleValueFrom`
now avoids the `sampleFrom` wrapper call while preserving stream shape and
existing weighted-choice behavior. This is reliability/ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
