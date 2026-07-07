# S4-M582 Root Item-Accessor Weighted Mutable-Pointer Array Sample Helpers

## Gap

S4-M581 added root item-accessor weighted fixed-size const-pointer array sample
helpers, but callers that wanted stack-friendly fixed-size no-replacement
weighted `*T` arrays from mutable item-local weights still had to construct a
secure engine manually and call `seq.sampleWeightedMutPtrArrayBy*`.

Rust `rand` exposes weighted no-replacement sampling through weighted index
workflows. Alea already has the lower-level Zig-native sequence primitive; this
milestone closes the root ergonomics gap for fixed-size item-accessor weighted
mutable-pointer arrays without adding Rust trait-shaped API machinery.

## API Added

`src/root.zig` now exposes:

- `sampleWeightedMutPtrArrayBy`
- `sampleWeightedMutPtrArrayByChecked`

Both helpers take a mutable item slice and a comptime item-weight accessor. The
unchecked helper returns `?[N]*T`, returning `null` when there are not enough
positive-weight items; the checked helper requires enough positive-weight items
and rejects insufficient/all-zero requests with `error.InvalidParameter`.

Deterministic pre-entropy behavior is explicit:

- `N == 0` returns an empty array before validating weights or drawing entropy.
- Empty/all-zero unchecked item weights return `null` for non-empty arrays.
- All-zero or insufficient checked item weights return `error.InvalidParameter`.
- A single positive item returns a one-pointer array before entropy is requested
  when the request can be satisfied.
- Invalid weights fail before entropy is requested.
- Multi-positive sampling uses the root secure engine and delegates to
  `seq.sampleWeightedMutPtrArrayBy*`.

The focused deterministic test writes through a returned pointer on the
single-positive path to prove callers receive mutable borrows into the original
slice.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byMutPtrArray=` in the dedicated
  `root weighted by no-replacement helpers` output line using a mutable item
  slice plus a comptime item-weight accessor.
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

Runnable example excerpt showing the guarded root item-accessor weighted mutable-pointer-array token:

```text
$ zig build run-basic | grep "root weighted by no-replacement helpers"
root weighted by no-replacement helpers: byIndexIndices={ 0, 2 }, byIndexIndicesInto={ 0, 1 }, byIndexIndicesU32={ 0, 1 }, byIndexIndicesU32Into={ 2, 1 }, byIndexVecIndices={ 2, 1 }, byIndexArrayIndices={ 1, 2 }, byIndexArrayIndicesU32={ 1, 2 }, byIndices={ 1, 2 }, byIndicesInto={ 1, 2 }, byIndicesU32={ 1, 2 }, byIndexVec={ 1, 2 }, byIndexArray={ 1, 2 }, byIndexArrayU32={ 1, 2 }, byValueArray=[blue, green], byPtrArray=[green, blue], byMutPtrArray=[green, blue], bySample=[green, blue], byInto=[green, blue], byPtrInto=[green, blue], byPtrSample=[red, blue], byMutPtrInto=[green, blue], byMutPtrSample=[green, blue]
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
apicheck ok
readmecheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M582 is closed for the current bar: root system-entropy callers can produce
fixed-size no-replacement weighted mutable-pointer arrays directly from a
mutable item slice and comptime item-weight accessor without manually
constructing a secure engine or parallel weight slice. This is API ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
