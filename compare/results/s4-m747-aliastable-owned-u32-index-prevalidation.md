# S4-M747 AliasTable Owned U32 Index Prevalidation

## Gap

S4-M746 tightened allocation-returning compact `u32` index helpers for
unweighted choice samplers. Static `AliasTable.indicesU32From` had the same
shape of gap: it allocated the output buffer and then delegated to the checked
fill path for compact-width validation.

For oversized alias tables, the allocation-returning compact index helper should
reject the table width before allocation and before random-stream use, matching
scalar, fill, fixed-array, and checked iterator compact `u32` paths.

## Local `rand` Baseline

The local Rust `rand` weighted-index APIs are `usize`-oriented. Alea's compact
`u32` weighted index outputs are an explicit Zig-native extension, so their width
contract must be deterministic: populations larger than `u32` fail as
`error.InvalidParameter` before allocation or stream consumption.

## Coverage Added

`src/distributions.zig` now prevalidates `AliasTable(Weight).indicesU32From`
before allocation. The focused alias-table iterator test already constructs a
fake oversized table for compact iterator width coverage; it now also verifies:

- `AliasTable.indicesU32From` returns `error.InvalidParameter`;
- a failing allocator is not triggered;
- the random stream is unchanged.

The fake table is never sampled or deinitialized; it only exercises the length
prevalidation branch without allocating impossible memory.

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
toolingcheck ok
examplecheck ok
readmecheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M747 is closed for the current bar: static `AliasTable` allocation-returning
compact `u32` index output now rejects oversized tables before allocation or
random-stream use. This is reliability/validation work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
