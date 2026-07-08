# S4-M900 WeightedChoice Checked Sample Direct Table Paths

## Gap

Reusable `WeightedChoice.sampleValueCheckedFrom`,
`WeightedChoice.sampleIndexCheckedFrom`, and `WeightedChoice.sampleIndexU32CheckedFrom`
still validated checked preconditions and then routed through unchecked scalar
sample helpers. Those unchecked helpers ultimately sample the underlying
`AliasTable`, so the checked scalar APIs can call the table directly after
validation and preserve stream shape while avoiding wrapper hops.

## Local `rand` Baseline

Local Rust `rand` weighted choice workflows build reusable weighted-index
samplers and then map sampled indexes back to items. Alea's reusable
`WeightedChoice` follows the same core model with Zig-native checked value,
`usize`, and compact `u32` helpers. For validated weighted choices, checked
scalar samples should use the cached alias table directly and only map indexes
into item storage where needed.

## Implementation

- `src/seq.zig` updates `WeightedChoice.sampleIndexCheckedFrom` to call the
  underlying `AliasTable.sampleCheckedFrom` directly.
- `src/seq.zig` updates `WeightedChoice.sampleIndexU32CheckedFrom` to keep the
  oversized-population check and then call `AliasTable.sampleU32CheckedFrom`
  directly.
- `src/seq.zig` updates `WeightedChoice.sampleValueCheckedFrom` to keep
  empty-enum prevalidation and then map a direct checked table sample into item
  storage.
- The focused weighted-choice test now compares checked scalar samples against
  direct table samples for value, `usize`, and compact `u32` stream shape while
  existing coverage preserves empty-enum and allocation/no-consume behavior.

## Validation

Focused reusable weighted choice test:

```text
$ zig test src/seq.zig --test-filter "weighted choice sampler maps alias indexes to items"
1/2 seq.test.weighted choice sampler maps alias indexes to items...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
apicheck ok
readmecheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M900 is closed for the current bar: reusable `WeightedChoice` checked scalar
value/index/u32 samples now avoid unchecked sampling wrappers after prevalidation
and use the cached alias table directly while preserving stream shape and checked
error behavior. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
