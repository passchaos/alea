# S4-M886 Choice Value Sample Direct Index Mapping

## Gap

Reusable `Choice.sampleValueFrom` still routed scalar value sampling through
`Choice.sampleFrom`, adding a pointer-wrapper call before copying the selected
item.

## Local `rand` Baseline

Local `rand` slice choice helpers sample a uniform index and then return/copy the
selected item. Alea's reusable `Choice` stores the item slice directly and already
has direct uniform index sampling, so scalar value sampling can generate the
index and copy `items[index]` directly while preserving the same stream as the
existing pointer/index paths.

## Implementation

- `src/seq.zig` updates `Choice.sampleValueFrom` to return the singleton item
  without entropy and otherwise sample a uniform index directly before copying
  `items[index]`, instead of routing through `Choice.sampleFrom`.
- Focused tests compare `Choice.sampleValueFrom` output with helper-generated
  indexes under identical seeds; existing focused coverage still checks pointer,
  fill, iterator, checked, and singleton behavior.

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
toolingcheck ok
readmecheck ok
roadmapcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M886 is closed for the current bar: reusable `Choice.sampleValueFrom` now
avoids the `Choice.sampleFrom` pointer wrapper call while preserving stream shape
and existing choice behavior. This is reliability/ergonomics work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
