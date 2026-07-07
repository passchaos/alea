# S4-M746 Choice Owned U32 Index Prevalidation

## Gap

Alea's compact `u32` index helpers are a Zig-native extension beyond local
Rust's `usize`-oriented choice indexes. Scalar, fill, fixed-array, and iterator
compact choice helpers already rejected populations larger than `u32`, but the
allocation-returning compact index helpers for distribution-layer `Choose` and
reusable `Choice` allocated their output buffer before delegating to the checked
fill path.

That meant an oversized population with a non-zero requested output amount could
report allocator failure before reporting `error.InvalidParameter`, and the
no-allocation/no-consumption prevalidation contract was weaker than surrounding
compact index APIs.

## Local `rand` Baseline

The local Rust `rand` sequence choice APIs are reference/index oriented and do
not expose an Alea-style compact `u32` owned-index extension. Alea keeps the
extension, but requires the width contract to be explicit and deterministic:
populations that cannot fit in `u32` reject before allocation and before random
stream use.

## Coverage Added

`src/seq.zig` now prevalidates `Choice(T).indicesU32From` before allocation.
`Choice(T).indicesU32CheckedFrom` inherits the same behavior.

`src/distributions.zig` now prevalidates `Choose(T).indicesU32From` before
allocation. `Choose(T).indicesU32CheckedFrom` inherits the same behavior.

Focused tests use fake oversized slices with length `maxInt(u32) + 1` and a
failing allocator to verify:

- `Choice.indicesU32From` returns `error.InvalidParameter`;
- `Choice.indicesU32CheckedFrom` returns `error.InvalidParameter`;
- `Choose.indicesU32From` returns `error.InvalidParameter`;
- `Choose.indicesU32CheckedFrom` returns `error.InvalidParameter`;
- no allocation failure is induced;
- the random stream is unchanged.

The fake oversized slices are never sampled; they only exercise width
prevalidation without allocating impossible memory.

## Validation

Focused sequence test:

```text
$ zig test src/seq.zig --test-filter "Choice owned u32 indices reject oversized population"
1/2 seq.test.Choice owned u32 indices reject oversized population before allocation...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "distribution Choose owned u32 indices reject oversized population"
1/2 distributions.test.distribution Choose owned u32 indices reject oversized population before allocation...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
apicheck ok
roadmapcheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M746 is closed for the current bar: allocation-returning compact `u32` index
helpers for distribution-layer `Choose` and reusable `Choice` now reject
oversized populations before allocation or random-stream use. This is
reliability/validation work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
