# S4-M580 Root Item-Accessor Weighted Value Array Sample Helpers

## Gap

S4-M579 completed the root length-weighted compact `u32` index array helpers,
but callers that wanted stack-friendly fixed-size no-replacement weighted value
arrays from item-local weights still had to construct a secure engine manually
and call `seq.sampleWeightedArrayBy*`.

Rust `rand` exposes weighted no-replacement sampling through weighted index
workflows. Alea already has the lower-level Zig-native sequence primitive; this
milestone closes the root ergonomics gap for fixed-size item-accessor weighted
value arrays without adding Rust trait-shaped API machinery.

## API Added

`src/root.zig` now exposes:

- `sampleWeightedArrayBy`
- `sampleWeightedArrayByChecked`

Both helpers take an item slice and a comptime item-weight accessor. The
unchecked helper returns `?[N]T`, returning `null` when there are not enough
positive-weight items; the checked helper requires enough positive-weight items
and rejects insufficient/all-zero requests with `error.InvalidParameter`.

Deterministic pre-entropy behavior is explicit:

- `N == 0` returns an empty array before validating weights or drawing entropy.
- Empty/all-zero unchecked item weights return `null` for non-empty arrays.
- All-zero or insufficient checked item weights return `error.InvalidParameter`.
- A single positive item returns a one-value array before entropy is requested
  when the request can be satisfied.
- Invalid weights fail before entropy is requested.
- Multi-positive sampling uses the root secure engine and delegates to
  `seq.sampleWeightedArrayBy*`.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byValueArray=` in the dedicated
  `root weighted by no-replacement helpers` output line using an item slice plus
  a comptime item-weight accessor.
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

Runnable example excerpt showing the guarded root item-accessor weighted value-array token:

```text
$ zig build run-basic | grep "root weighted by no-replacement helpers"
root weighted by no-replacement helpers: byIndexIndices={ 0, 1 }, byIndexIndicesInto={ 0, 2 }, byIndexIndicesU32={ 1, 0 }, byIndexIndicesU32Into={ 1, 0 }, byIndexVecIndices={ 2, 1 }, byIndexArrayIndices={ 0, 2 }, byIndexArrayIndicesU32={ 1, 2 }, byIndices={ 2, 1 }, byIndicesInto={ 0, 2 }, byIndicesU32={ 0, 2 }, byIndexVec={ 2, 1 }, byIndexArray={ 1, 2 }, byIndexArrayU32={ 0, 2 }, byValueArray=[green, blue], bySample=[green, blue], byInto=[red, blue], byPtrInto=[green, blue], byPtrSample=[red, blue], byMutPtrInto=[red, blue], byMutPtrSample=[green, blue]
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
toolingcheck ok
apicheck ok
examplecheck ok
readmecheck ok
```

## Result

S4-M580 is closed for the current bar: root system-entropy callers can produce
fixed-size no-replacement weighted value arrays directly from an item slice and
comptime item-weight accessor without manually constructing a secure engine or
parallel weight slice. This is API ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
