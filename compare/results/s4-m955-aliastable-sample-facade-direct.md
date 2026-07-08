# S4-M955 AliasTable Sample Facade Direct Paths

## Gap

Static `AliasTable.sample` and `AliasTable.sampleChecked` facade helpers still
routed through direct-source sample wrappers. Index and compact facade aliases
were already direct, so canonical facade samples should execute the same
alias-table sampling branches directly while preserving stream shape.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` weighted-index workflows sample indexes directly
through an RNG reference. Alea's `AliasTable` facade `sample` helpers should
preserve this direct weighted-index sampling shape without routing through
`From` wrappers.

## Implementation

- `src/distributions.zig` updates `AliasTable.sample` to execute constant-index,
  one-word power-of-two, and general alias-table sampling directly through the
  facade `Rng`.
- `src/distributions.zig` updates `AliasTable.sampleChecked` to execute the same
  direct sampling branches through the facade `Rng`.
- Focused tests compare facade sample/index aliases against direct sample helpers
  for stream shape.

## Validation

Focused AliasTable tests:

```text
$ zig test src/distributions.zig --test-filter "alias table index aliases mirror sample helpers"
1/2 distributions.test.alias table index aliases mirror sample helpers...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "alias table u32 sampling helpers mirror usize helpers"
1/2 distributions.test.alias table u32 sampling helpers mirror usize helpers...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
roadmapcheck ok
examplecheck ok
apicheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M955 is closed for the current bar: static `AliasTable.sample` and
`sampleChecked` now avoid direct-source sample wrapper aliases while preserving
stream shape and constant-index behavior. This is reliability/ergonomics work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
