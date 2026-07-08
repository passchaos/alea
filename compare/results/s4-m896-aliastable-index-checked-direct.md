# S4-M896 AliasTable Checked Index Alias Direct Path

## Gap

Static `AliasTable.sampleIndexCheckedFrom` still routed the checked index alias
through `sampleCheckedFrom`, adding an alias wrapper before the direct alias-table
sampling path.

## Local `rand` Baseline

Local `rand` weighted-index workflows sample indexes directly from reusable
weighted samplers. Alea's `AliasTable` checked index alias can execute the same
constant, one-word, and general alias-table sampling paths directly while keeping
its checked API shape and stream behavior.

## Implementation

- `src/distributions.zig` updates `AliasTable.sampleIndexCheckedFrom` to execute
  the constant-index, power-of-two one-word, and general column/probability
  sampling paths directly instead of calling `sampleCheckedFrom`.
- Focused tests compare checked index alias stream shape and behavior.

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
examplecheck ok
readmecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M896 is closed for the current bar: `AliasTable.sampleIndexCheckedFrom` now
avoids an alias wrapper and executes alias-table sampling directly while
preserving stream shape. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
