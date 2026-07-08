# S4-M815 AliasTable U32 Iterator Direct Checked Sampling

## Gap

S4-M805 optimized static `AliasTable` bulk index fills. The compact
`AliasTable.U32IndexIterator.nextValue` path still routed each scalar iterator
item through `sampleU32From`, which then forwarded to the checked sampler.

## Local `rand` Baseline

Rust weighted-index iterator workflows sample directly from the weighted-index
distribution. Alea's static `AliasTable` compact iterator should similarly call
the table's checked compact sampler directly after iterator construction has
validated width.

## Implementation

- `src/distributions.zig` updates `AliasTable.U32IndexIterator.nextValue` to call
  `sampleU32CheckedFrom` directly.
- Focused tests compare compact iterator `next()` output with
  `sampleU32CheckedFrom` under identical seeds, proving stream shape stays
  aligned.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "alias table exposes totals"
1/2 distributions.test.alias table exposes totals and reconstructs weights...OK
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

S4-M815 is closed for the current bar: static `AliasTable` compact u32 iterator
scalar `next()` calls now avoid the `sampleU32From` wrapper and call the checked
table sampler directly while preserving stream shape. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
