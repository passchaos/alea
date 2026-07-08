# S4-M819 WeightedChoice Value Iterator Direct Table Mapping

## Gap

S4-M804 optimized reusable `WeightedChoice` value fills by mapping alias-table
indexes directly into item storage. The scalar `WeightedChoice.ValueIterator`
path still routed each item through `sampleValueFrom`, adding a wrapper call for
every iterator element.

## Local `rand` Baseline

Rust weighted choice iterators sample weighted indexes from the underlying
weighted-index distribution and map them to items. Alea's reusable
`WeightedChoice` wraps an `AliasTable`, so value iterators should map direct table
samples into item storage while preserving weighted stream shape.

## Implementation

- `src/seq.zig` updates `WeightedChoice.ValueIterator.nextValue` to return `null`
  for empty-enum output types, sample the underlying alias table directly, and
  map the sampled index to `items[index]`.
- Focused tests compare iterator `next()` output with direct table-index mapping
  under identical seeds, proving stream shape stays aligned.

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
readmecheck ok
toolingcheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M819 is closed for the current bar: reusable `WeightedChoice` value iterator
scalar `next()` calls now avoid per-item `sampleValueFrom` wrapper calls and map
alias-table indexes directly into item storage while preserving weighted stream
shape. This is reliability/ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
