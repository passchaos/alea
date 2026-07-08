# S4-M908 AliasTable U32 Facade Sample Direct Paths

## Gap

`AliasTable.sampleU32` and `AliasTable.sampleU32Checked` still routed through
checked helper wrappers before reaching compact u32 alias-table sampling. Index
facade aliases were made direct in S4-M906 and S4-M907, but compact facade sample
helpers retained wrapper hops.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` weighted-index workflows sample indexes directly
through an RNG reference. Alea's `AliasTable` adds compact `u32` facade helpers
for smaller index buffers; those helpers should preserve stream shape while
executing the compact alias-table sampling branches directly.

## Implementation

- `src/distributions.zig` updates `AliasTable.sampleU32` to execute compact u32
  constant-index, one-word power-of-two, and general alias-table branches directly
  through the facade `Rng`.
- `src/distributions.zig` updates `AliasTable.sampleU32Checked` to keep compact
  output-size validation and then execute the same direct u32 alias-table
  branches through the facade `Rng`.
- The focused AliasTable alias test compares facade compact samples and checked
  compact samples against direct checked u32 helpers for stream shape.

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
readmecheck ok
toolingcheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M908 is closed for the current bar: `AliasTable.sampleU32` and
`sampleU32Checked` now avoid checked helper wrappers while preserving stream
shape, compact output validation, and constant-index behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
