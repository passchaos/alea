# S4-M948 AliasTable Checked U32 Iterator From Direct Constructor

## Gap

Static `AliasTable.iterU32CheckedFrom` still routed through the unchecked compact
`iterU32From` constructor after width validation. The checked direct-source
constructor can build the compact iterator payload directly while preserving the
same validation and stream shape.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` weighted-index workflows are iterator-oriented.
Alea's compact `u32` iterator is a Zig-native extension for smaller index
buffers, and checked direct-source construction should validate width and then
construct the iterator directly.

## Implementation

- `src/distributions.zig` updates `AliasTable.iterU32CheckedFrom` to keep compact
  width prevalidation and return the `U32IndexIterator` payload directly.
- Focused tests compare checked compact direct-source iterators against unchecked
  compact iterators and cover oversized compact iterator prevalidation.

## Validation

Focused AliasTable test:

```text
$ zig test src/distributions.zig --test-filter "alias table iterators produce repeated indices"
1/2 distributions.test.alias table iterators produce repeated indices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
toolingcheck ok
examplecheck ok
readmecheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M948 is closed for the current bar: static `AliasTable.iterU32CheckedFrom` now
avoids the unchecked compact iterator constructor wrapper while preserving stream
shape and compact width validation. This is reliability/ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
