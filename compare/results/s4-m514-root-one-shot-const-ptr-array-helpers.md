# S4-M514 Root One-Shot No-Replacement Fixed-Size Const-Pointer Array Helpers

## Gap

S4-M513 added root fixed-size no-replacement value arrays. Fixed-size
no-replacement const-pointer arrays still required constructing a secure engine
and using `seq.samplePtrArray*` directly.

## API Added

`src/root.zig` now exposes:

- `samplePtrArray`
- `samplePtrArrayChecked`

Zero-size arrays and all-item arrays return without drawing entropy. The checked
helper rejects oversized requests before entropy is requested.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `samplePtrArray` in root no-replacement
  helper output.
- `tools/examplecheck.zig` guards that example token.
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

Runnable example and guard checks:

```text
$ zig build run-basic
root no-replacement helpers: sample={ 2, 3, 4 }, sampleArray={ 3, 2, 1 }, samplePtrArray=[2, 4, 3], indices={ 5, 3, 2 }, indexVec={ 3, 1, 2 }, indexArray={ 3, 5, 0 }, indexArrayU32={ 2, 4, 0 }, indicesInto={ 3, 5, 0 }, indicesU32={ 5, 3, 2 }, weightedIndices={ 0, 2 }, weightedIndexVec={ 0, 2 }, weightedIndexArray={ 0, 2 }, weightedIndexArrayU32={ 1, 2 }, weightedIndicesInto={ 1, 2 }, weightedIndicesU32Into={ 1, 2 }, weightedValues=[green, blue], weightedValuesInto=[green, blue], weightedArray=[red, blue], weightedPtrs=[red, blue], weightedPtrsInto=[green, blue], weightedMutPtrs=[blue, green], weightedMutPtrsInto=[green, blue]
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

Broader native test gate:

```text
$ zig build test
readmecheck ok
examplecheck ok
toolingcheck ok
apicheck ok
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M514 is closed for the current bar: root system-entropy callers can produce
fixed-size no-replacement const-pointer arrays without manually constructing a
secure engine. This is API ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
