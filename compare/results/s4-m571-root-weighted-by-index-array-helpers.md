# S4-M571 Root Item-Accessor Weighted Index Array Helpers

## Gap

S4-M570 added root item-accessor weighted `usize` index caller-owned buffer
helpers, but callers that wanted stack-friendly fixed-size no-replacement
weighted `usize` index arrays from item-local weights still had to construct a
secure engine manually and call `seq.sampleWeightedIndexArrayBy*`.

Rust `rand` exposes weighted no-replacement index workflows through weighted
index sampling. Alea already has the lower-level Zig-native sequence primitive;
this milestone closes the root ergonomics gap for stack-friendly item-accessor
`usize` index arrays without adding Rust trait-shaped API machinery.

## API Added

`src/root.zig` now exposes:

- `sampleWeightedIndexArrayBy`
- `sampleWeightedIndexArrayByChecked`

Both helpers take an item slice and a comptime item-weight accessor. The
unchecked helper returns `?[N]usize`, returning `null` when there are not enough
positive-weight items; the checked helper requires enough positive-weight items
and rejects insufficient/all-zero requests with `error.InvalidParameter`.

Deterministic pre-entropy behavior is explicit:

- `N == 0` returns an empty array before validating weights or drawing entropy.
- Empty/all-zero unchecked item weights return `null` for non-empty arrays.
- All-zero or insufficient checked item weights return `error.InvalidParameter`.
- A single positive item returns a one-index array before entropy is requested
  when the request can be satisfied.
- Invalid weights fail before entropy is requested.
- Multi-positive sampling uses the root secure engine and delegates to
  `seq.sampleWeightedIndexArrayBy*`.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byIndexArray=` in the dedicated
  `root weighted by no-replacement helpers` output line using a slice of structs
  plus an item-weight accessor.
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

Runnable example excerpt showing the guarded root item-accessor weighted index-array token:

```text
$ zig build run-basic | grep "root weighted by no-replacement helpers"
root weighted by no-replacement helpers: byIndices={ 1, 2 }, byIndicesInto={ 0, 2 }, byIndicesU32={ 1, 2 }, byIndexVec={ 0, 2 }, byIndexArray={ 1, 2 }, bySample=[green, blue], byInto=[blue, green], byPtrInto=[green, blue], byPtrSample=[blue, green], byMutPtrInto=[green, blue], byMutPtrSample=[red, blue]
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
toolingcheck ok
apicheck ok
examplecheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M571 is closed for the current bar: root system-entropy callers can produce
fixed-size no-replacement weighted `usize` index arrays directly from an item
slice and comptime item-weight accessor without manually constructing a secure
engine or parallel weight slice. This is API ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
