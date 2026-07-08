# S4-M892 AliasTable Index Alias Direct Checked Path

## Gap

Static `AliasTable.sampleIndexFrom` still routed the Rust-discoverable index alias
through `sampleFrom`, adding an alias wrapper before reaching the table sampling
path.

## Local `rand` Baseline

Local `rand` weighted-index workflows sample indexes directly from reusable
weighted samplers. Alea's `AliasTable` already has a checked index sampler that
encodes the direct alias-table sampling path, so `sampleIndexFrom` can call that
checked path directly while preserving stream shape and existing unchecked alias
behavior.

## Implementation

- `src/distributions.zig` updates `AliasTable.sampleIndexFrom` to call
  `sampleCheckedFrom(source) catch unreachable` directly instead of routing
  through `sampleFrom`.
- Focused tests already compare `sampleFrom` and `sampleIndexFrom` stream shape
  and checked index alias behavior.

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
examplecheck ok
toolingcheck ok
apicheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M892 is closed for the current bar: `AliasTable.sampleIndexFrom` now avoids
one alias wrapper and reaches the checked sampler path directly while preserving
stream shape. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
