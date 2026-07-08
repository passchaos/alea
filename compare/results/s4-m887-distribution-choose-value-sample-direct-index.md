# S4-M887 Distribution Choose Value Sample Direct Index Mapping

## Gap

Distribution-layer `Choose.sampleValueFrom` still routed scalar value sampling
through `Choose.sampleFrom`, adding a pointer-wrapper call before copying the
selected item.

## Local `rand` Baseline

Local `rand` slice choice helpers sample a uniform index and then return/copy the
selected item. Alea's distribution-layer `Choose` stores the item slice directly
and already has direct uniform index sampling, so scalar value sampling can
generate the index and copy `items[index]` directly while preserving the same
stream as the existing pointer/index paths.

## Implementation

- `src/distributions.zig` updates `Choose.sampleValueFrom` to return the singleton
  item without entropy and otherwise sample a uniform index directly before
  copying `items[index]`, instead of routing through `Choose.sampleFrom`.
- Focused tests compare `Choose.sampleValueFrom` output with helper-generated
  indexes under identical seeds; existing focused coverage still checks pointer,
  fill, iterator, checked, and singleton behavior.

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
roadmapcheck ok
readmecheck ok
apicheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M887 is closed for the current bar: distribution-layer `Choose.sampleValueFrom`
now avoids the `Choose.sampleFrom` pointer wrapper call while preserving stream
shape and existing choice behavior. This is reliability/ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
