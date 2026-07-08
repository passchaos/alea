# S4-M963 AliasTable U32 From Direct Refresh

## Gap

A current-code audit found `AliasTable.sampleU32From` and
`AliasTable.sampleIndexU32From` routing through `sampleU32CheckedFrom(source)
catch unreachable` again. The actual current compact direct-source aliases should
execute compact alias-table sampling branches directly while preserving stream
shape and unchecked alias semantics.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` weighted-index workflows sample indexes directly
from reusable weighted samplers. Alea's compact `u32` aliases are Zig-native
smaller-index conveniences and should avoid checked wrapper hops in the current
codebase.

## Implementation

- `src/distributions.zig` updates `AliasTable.sampleU32From` to execute compact
  constant-index, one-word power-of-two, and general alias-table sampling branches
  directly from the provided source.
- `src/distributions.zig` updates `AliasTable.sampleIndexU32From` with the same
  direct compact sampling branches.
- Focused tests compare compact alias stream shape against `usize` helpers and
  index aliases.

## Validation

Focused AliasTable tests:

```text
$ zig test src/distributions.zig --test-filter "alias table u32 sampling helpers mirror usize helpers"
1/2 distributions.test.alias table u32 sampling helpers mirror usize helpers...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "alias table index aliases mirror sample helpers"
1/2 distributions.test.alias table index aliases mirror sample helpers...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M963 is closed for the current bar: `AliasTable.sampleU32From` and
`sampleIndexU32From` again match the direct compact alias-table sampling intent in
the current codebase while preserving stream shape. This is reliability/ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
