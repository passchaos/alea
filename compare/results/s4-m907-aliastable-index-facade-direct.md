# S4-M907 AliasTable Index Facade Aliases Direct Paths

## Gap

`AliasTable.sampleIndex` and `AliasTable.sampleIndexU32` still routed through
`sample` / `sampleU32` facade wrappers. Checked facade index aliases were made
direct in S4-M906, but unchecked facade index aliases retained one wrapper before
executing the same alias-table sampling branches.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` weighted-index workflows sample indexes directly
through an RNG reference. Alea's `AliasTable` keeps Zig-native facade aliases for
`usize` and compact `u32` index outputs; those aliases should preserve stream
shape while executing alias-table sampling directly.

## Implementation

- `src/distributions.zig` updates `AliasTable.sampleIndex` to execute the
  constant-index, one-word power-of-two, and general alias-table branches directly
  through the facade `Rng`.
- `src/distributions.zig` updates `AliasTable.sampleIndexU32` to validate compact
  output size in the same infallible contract as `sampleU32`, then execute direct
  u32 alias-table branches through the facade `Rng`.
- The focused AliasTable alias test compares facade `sampleIndex` and
  `sampleIndexU32` aliases against direct facade sample helpers for stream shape.

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
readmecheck ok
toolingcheck ok
apicheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M907 is closed for the current bar: `AliasTable.sampleIndex` and
`sampleIndexU32` now avoid facade wrapper aliases while preserving stream shape,
constant-index behavior, and compact output behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
