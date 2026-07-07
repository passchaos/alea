# S4-M579 Root Length-Weighted Compact U32 Index Array Helpers

## Gap

S4-M578 added root length-weighted fixed-size `usize` index array helpers, but
callers that wanted stack-friendly fixed-size no-replacement weighted compact
`u32` index arrays from a length and comptime index-weight accessor still had to
construct a secure engine manually and call
`seq.sampleWeightedIndexArrayU32ByIndex*`.

Rust `rand` exposes length-based weighted no-replacement index workflows through
`index::sample_weighted(rng, length, |index| ...)`. Alea already has the
lower-level Zig-native sequence primitive; this milestone closes the root
ergonomics gap for stack-friendly length-weighted compact `u32` index arrays
without adding Rust trait-shaped API machinery.

## API Added

`src/root.zig` now exposes:

- `sampleWeightedIndexArrayU32ByIndex`
- `sampleWeightedIndexArrayU32ByIndexChecked`

Both helpers take a length and a comptime index-weight accessor. The unchecked
helper returns `?[N]u32`, returning `null` when there are not enough
positive-weight indexes; the checked helper requires enough positive-weight
indexes and rejects insufficient/all-zero requests with `error.InvalidParameter`.
Both helpers reject lengths greater than `maxInt(u32)` before attempting to
sample.

Deterministic pre-entropy behavior is explicit:

- `N == 0` returns an empty array before validating weights or drawing entropy.
- Oversized lengths return `error.InvalidParameter` before entropy.
- Empty/all-zero unchecked index weights return `null` for non-empty arrays.
- All-zero or insufficient checked index weights return `error.InvalidParameter`.
- A single positive index returns a one-index array before entropy is requested
  when the request can be satisfied.
- Invalid weights fail before entropy is requested.
- Multi-positive sampling uses the root secure engine and delegates to
  `seq.sampleWeightedIndexArrayU32ByIndex*`.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byIndexArrayIndicesU32=` in the dedicated
  `root weighted by no-replacement helpers` output line using a length plus a
  comptime index-weight accessor.
- `tools/examplecheck.zig` guards the new example token.
- `docs/api-reference.md` lists the new root public symbols.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused root tests:

```text
$ zig test src/root.zig --test-filter "root random helpers"
1/3 root.test_0...OK
2/3 root.test.root random helpers use explicit system entropy...OK
3/3 root.test.root random helpers validate deterministic cases before entropy...OK
All 3 tests passed.
```

Runnable example excerpt showing the guarded root length-weighted compact u32 index-array token:

```text
$ zig build run-basic | grep "root weighted by no-replacement helpers"
root weighted by no-replacement helpers: byIndexIndices={ 2, 0 }, byIndexIndicesInto={ 1, 2 }, byIndexIndicesU32={ 1, 2 }, byIndexIndicesU32Into={ 0, 1 }, byIndexVecIndices={ 1, 2 }, byIndexArrayIndices={ 1, 2 }, byIndexArrayIndicesU32={ 0, 1 }, byIndices={ 1, 2 }, byIndicesInto={ 1, 2 }, byIndicesU32={ 0, 1 }, byIndexVec={ 0, 2 }, byIndexArray={ 1, 2 }, byIndexArrayU32={ 1, 2 }, bySample=[green, blue], byInto=[red, blue], byPtrInto=[blue, green], byPtrSample=[green, blue], byMutPtrInto=[red, green], byMutPtrSample=[green, blue]
```

```text
$ zig build examplecheck
examplecheck ok
```

```text
$ zig build apicheck
apicheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

Broader native test gate:

```text
$ zig build test
roadmapcheck ok
apicheck ok
toolingcheck ok
examplecheck ok
readmecheck ok
```

## Result

S4-M579 is closed for the current bar: root system-entropy callers can produce
fixed-size no-replacement weighted compact `u32` index arrays directly from a
length and comptime index-weight accessor without manually constructing a secure
engine or parallel weight slice. This is API ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
