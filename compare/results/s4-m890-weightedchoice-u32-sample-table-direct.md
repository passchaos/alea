# S4-M890 WeightedChoice U32 Index Sample Direct Table Path

## Gap

Reusable `WeightedChoice.sampleIndexU32From` still routed compact `u32` index
sampling through the `usize` `sampleIndexFrom` path and then cast the result,
adding a wrapper and missing the `AliasTable` compact checked sampler path.

## Local `rand` Baseline

Local `rand` weighted index workflows sample weighted indexes directly from a
reusable sampler. Alea's `WeightedChoice` stores an `AliasTable`, which already
has compact `u32` sampling support, so `WeightedChoice.sampleIndexU32From` can
call the table's compact sampler directly while preserving stream shape and the
existing checked oversized-population behavior.

## Implementation

- `src/seq.zig` updates `WeightedChoice.sampleIndexU32From` to keep the public
  oversized-population prevalidation and then call `self.table.sampleU32CheckedFrom`
  directly, mapping impossible internal table errors to `unreachable`.
- Focused tests compare `WeightedChoice.sampleIndexU32From` with direct
  `AliasTable.sampleU32CheckedFrom` output under identical seeds; existing tests
  still cover checked aliases, fill/iterator compact paths, and single-positive
  no-consume behavior.

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
readmecheck ok
toolingcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M890 is closed for the current bar: reusable `WeightedChoice.sampleIndexU32From`
now uses the compact `AliasTable` sampler directly while preserving stream shape
and public error behavior. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
