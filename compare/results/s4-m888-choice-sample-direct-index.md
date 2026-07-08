# S4-M888 Choice Sample Direct Index Mapping

## Gap

Reusable `Choice.sampleFrom` still routed scalar pointer sampling through
`Choice.sampleIndexFrom`, adding a wrapper call before generating the uniform
index and mapping into the item slice.

## Local `rand` Baseline

Local `rand` slice choice helpers sample a uniform index and then return a
reference to the selected item. Alea's reusable `Choice` stores the item slice
directly and has all metadata needed to sample the index and map to `items[index]`
in one place while preserving the same stream as the existing index path.

## Implementation

- `src/seq.zig` updates `Choice.sampleFrom` to return the singleton pointer
  without entropy and otherwise sample a uniform index directly before returning
  `&items[index]`, instead of routing through `Choice.sampleIndexFrom`.
- Focused tests compare `Choice.sampleFrom` output with helper-generated indexes
  under identical seeds; existing focused coverage still checks value, fill,
  iterator, checked, and singleton behavior.

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
roadmapcheck ok
apicheck ok
readmecheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M888 is closed for the current bar: reusable `Choice.sampleFrom` now avoids
the `Choice.sampleIndexFrom` wrapper call while preserving stream shape and
existing choice behavior. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
