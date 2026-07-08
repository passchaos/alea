# S4-M894 AliasTable Checked Sample Direct Path

## Gap

Static `AliasTable.sampleCheckedFrom` still routed checked index sampling through
unchecked `AliasTable.sampleFrom`, adding a wrapper before the direct alias-table
sampling path.

## Local `rand` Baseline

Local `rand` weighted-index workflows sample indexes directly from reusable
weighted samplers. Alea's `AliasTable` checked sampler can execute the same
constant, one-word, and general alias-table sampling paths directly while keeping
its checked API shape and stream behavior.

## Implementation

- `src/distributions.zig` updates `AliasTable.sampleCheckedFrom` to execute the
  constant-index, power-of-two one-word, and general column/probability sampling
  paths directly instead of calling `sampleFrom`.
- Focused tests compare `sampleCheckedFrom` and `sampleIndexCheckedFrom` stream
  shape and alias behavior.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "alias table index aliases mirror sample helpers"
1/2 distributions.test.alias table index aliases mirror sample helpers...OK
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
toolingcheck ok
readmecheck ok
```

## Result

S4-M894 is closed for the current bar: `AliasTable.sampleCheckedFrom` now avoids
an unchecked wrapper and executes alias-table sampling directly while preserving
stream shape. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
