# S4-M895 AliasTable U32 Checked Sample Direct Path

## Gap

Static `AliasTable.sampleU32CheckedFrom` still routed compact checked sampling
through `sampleFrom` and cast the resulting `usize`, adding a wrapper and missing
the direct compact branch used by `fillU32CheckedFrom`.

## Local `rand` Baseline

Local `rand` weighted-index workflows sample indexes directly from reusable
weighted samplers. Alea's `AliasTable` has compact `u32` support for repeated
output, so the scalar checked compact sampler can execute the same constant,
one-word, and general alias-table sampling paths directly while preserving stream
shape and checked oversized-table validation.

## Implementation

- `src/distributions.zig` updates `AliasTable.sampleU32CheckedFrom` to keep the
  oversized table prevalidation, then execute constant-index, power-of-two
  one-word, and general column/probability compact sampling paths directly instead
  of calling `sampleFrom` and casting.
- Focused tests compare compact sampling aliases and checked behavior.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "alias table u32 sampling helpers mirror usize helpers"
1/2 distributions.test.alias table u32 sampling helpers mirror usize helpers...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M895 is closed for the current bar: `AliasTable.sampleU32CheckedFrom` now uses
the compact direct alias-table sampling path while preserving stream shape and
checked validation behavior. This is reliability/ergonomics work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
