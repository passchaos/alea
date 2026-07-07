# S4-M751 AliasTable Checked Fixed Index Arrays

## Gap

`docs/api-reference.md` and the S4-M741 documentation audit listed
`AliasTable.indexArrayChecked` and `AliasTable.indexArrayCheckedFrom`, but static
`AliasTable` only implemented the unchecked fixed-size `usize` index array
helpers plus checked compact `u32` fixed arrays. This left the documented public
surface ahead of the actual API.

## Local `rand` Baseline

The local Rust weighted-index workflow is index-oriented. Alea provides
Zig-native fixed-size array helpers for allocation-free batches; the checked
`usize` fixed-array aliases should exist alongside the checked scalar, fill,
owned, compact, and iterator aliases.

## API Added

`src/distributions.zig` now exposes:

- `AliasTable(Weight).indexArrayChecked`;
- `AliasTable(Weight).indexArrayCheckedFrom`.

The docs already listed these symbols; this milestone brings implementation and
focused test evidence in sync with that public surface.

## Coverage Added

The focused fixed-array test verifies:

- checked facade and checked direct-source fixed-size `usize` arrays preserve
  stream shape;
- zero-size checked arrays succeed without consuming randomness.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "alias table fixed index arrays mirror fills"
1/2 distributions.test.alias table fixed index arrays mirror fills...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
readmecheck ok
apicheck ok
examplecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M751 is closed for the current bar: static `AliasTable` now implements its
documented checked fixed-size `usize` index array aliases with stream-shape and
zero-size evidence. This is API-correctness/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
