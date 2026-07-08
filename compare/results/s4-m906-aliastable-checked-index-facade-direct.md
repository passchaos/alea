# S4-M906 AliasTable Checked Index Facade Aliases Direct Paths

## Gap

`AliasTable.sampleIndexChecked` and `AliasTable.sampleIndexU32Checked` still
routed through `sampleChecked` / `sampleU32Checked` facade wrappers. Direct-source
checked index aliases were already direct, but facade checked index aliases still
had one extra wrapper before executing the same alias-table sampling branches.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` weighted-index workflows sample indexes directly
through an RNG reference. Alea's `AliasTable` keeps Zig-native checked facade
aliases for `usize` and compact `u32` index outputs; those facade aliases should
preserve checked behavior and stream shape while executing alias-table sampling
directly.

## Implementation

- `src/distributions.zig` updates `AliasTable.sampleIndexChecked` to execute the
  constant-index, one-word power-of-two, and general alias-table branches directly
  through the facade `Rng`.
- `src/distributions.zig` updates `AliasTable.sampleIndexU32Checked` to keep
  compact output-size validation and then execute the direct u32 alias-table
  branches through the facade `Rng`.
- The focused AliasTable alias test already compares facade checked index and
  compact-index aliases against direct checked sample helpers for stream shape.

## Validation

Focused AliasTable alias test:

```text
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
roadmapcheck ok
examplecheck ok
readmecheck ok
apicheck ok
toolingcheck ok
```

## Result

S4-M906 is closed for the current bar: `AliasTable.sampleIndexChecked` and
`sampleIndexU32Checked` now avoid checked facade wrapper aliases while preserving
stream shape, compact output validation, and checked error behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
