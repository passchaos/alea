# S4-M891 AliasTable U32 Index Alias Direct Checked Path

## Gap

Static `AliasTable.sampleIndexU32From` still routed compact index sampling through
`sampleU32From`, adding one alias wrapper before reaching the checked compact
sampler.

## Local `rand` Baseline

Local `rand` weighted-index workflows sample indexes directly from reusable
weighted samplers. Alea's `AliasTable` already has a compact `u32` checked sampler
with direct validation, so the Rust-discoverable `sampleIndexU32From` alias can
call that checked compact path directly while preserving stream shape and the
existing unchecked alias behavior.

## Implementation

- `src/distributions.zig` updates `AliasTable.sampleIndexU32From` to call
  `sampleU32CheckedFrom(source) catch unreachable` directly instead of routing
  through `sampleU32From`.
- Focused tests already compare `sampleU32From` and `sampleIndexU32From` stream
  shape and checked u32 alias behavior.

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
readmecheck ok
roadmapcheck ok
toolingcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M891 is closed for the current bar: `AliasTable.sampleIndexU32From` now avoids
one alias wrapper and reaches the compact checked sampler directly while
preserving stream shape. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
