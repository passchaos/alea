# S4-M750 AliasTable Checked Owned U32 Indices

## Gap

Static `AliasTable` had checked scalar, fill, fixed-array, and iterator compact
`u32` APIs, and it had an unchecked allocation-returning `indicesU32` helper.
It did not expose checked allocation-returning compact `u32` aliases, leaving the
static weighted sampler less consistent than `Choice`, `WeightedChoice`, and the
dynamic weighted-tree types.

## Local `rand` Baseline

The local Rust weighted-index APIs are index-oriented and reusable. Alea's
compact `u32` owned index output is a Zig-native extension; checked aliases make
that extension explicit while preserving the existing stream shape and width
validation.

## API Added

`src/distributions.zig` now exposes:

- `AliasTable(Weight).indicesU32Checked`;
- `AliasTable(Weight).indicesU32CheckedFrom`.

`docs/api-reference.md` lists the new symbols.

## Coverage Added

The focused alias-table iterator test now verifies:

- checked owned compact `u32` indices match `indicesU32From` stream shape;
- checked owned compact `u32` aliases inherit oversized table width rejection;
- the oversized path returns `error.InvalidParameter` before allocation or
  random-stream use.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "alias table iterators produce repeated indices"
1/2 distributions.test.alias table iterators produce repeated indices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M750 is closed for the current bar: static `AliasTable` now has checked
allocation-returning compact `u32` index aliases with stream-shape parity and
width-prevalidation evidence. This is ergonomics/API-consistency work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
