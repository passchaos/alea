# S4-M752 AliasTable Checked Usize Index Aliases

## Gap

`docs/api-reference.md` and the S4-M741 documentation audit listed checked
`usize` index aliases for static `AliasTable`, including scalar, fill, and owned
batch helpers. The implementation only had the unchecked `usize` paths plus
checked compact `u32` paths and checked iterators/fixed arrays.

This meant the documented public surface for static `AliasTable` was ahead of
the actual API.

## Local `rand` Baseline

The local Rust weighted-index workflow is index-oriented. Alea's static
`AliasTable` provides reusable weighted index sampling with additional Zig-native
fill, owned batch, fixed-array, compact, and iterator helpers. The checked
`usize` aliases should exist consistently across those workflows while
preserving the existing stream shape.

## API Added

`src/distributions.zig` now exposes:

- `AliasTable(Weight).sampleChecked`;
- `AliasTable(Weight).sampleIndexChecked`;
- `AliasTable(Weight).sampleCheckedFrom`;
- `AliasTable(Weight).sampleIndexCheckedFrom`;
- `AliasTable(Weight).fillChecked`;
- `AliasTable(Weight).fillIndicesChecked`;
- `AliasTable(Weight).fillCheckedFrom`;
- `AliasTable(Weight).fillIndicesCheckedFrom`;
- `AliasTable(Weight).indicesChecked`;
- `AliasTable(Weight).indicesCheckedFrom`.

The docs already listed these symbols; this milestone brings implementation and
focused test evidence in sync with that public surface.

## Coverage Added

Focused tests verify:

- checked scalar aliases preserve sample/index stream shape;
- checked fill aliases preserve fill/index stream shape;
- checked owned aliases preserve facade/direct stream shape;
- zero-size checked owned batches preserve no-op behavior.

## Validation

Focused distribution tests:

```text
$ zig test src/distributions.zig --test-filter "alias table index aliases mirror sample helpers"
1/2 distributions.test.alias table index aliases mirror sample helpers...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/distributions.zig --test-filter "alias table owned index batches mirror fills"
1/2 distributions.test.alias table owned index batches mirror fills...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
roadmapcheck ok
readmecheck ok
examplecheck ok
apicheck ok
toolingcheck ok
```

## Result

S4-M752 is closed for the current bar: static `AliasTable` now implements its
documented checked scalar, fill, and owned `usize` index aliases with stream-shape
and zero-size evidence. This is API-correctness/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
