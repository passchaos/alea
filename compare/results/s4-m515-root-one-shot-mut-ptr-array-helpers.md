# S4-M515 Root One-Shot No-Replacement Fixed-Size Mutable-Pointer Array Helpers

## Gap

S4-M514 added root fixed-size no-replacement const-pointer arrays. Fixed-size
no-replacement mutable-pointer arrays still required constructing a secure engine
and using `seq.sampleMutPtrArray*` directly.

## API Added

`src/root.zig` now exposes:

- `sampleMutPtrArray`
- `sampleMutPtrArrayChecked`

Zero-size arrays and all-item arrays return without drawing entropy. The checked
helper rejects oversized requests before entropy is requested.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `sampleMutPtrArray` in root no-replacement
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
root no-replacement helpers: sample={ 4, 5, 3 }, sampleArray={ 2, 6, 4 }, samplePtrArray=[1, 4, 2], sampleMutPtrArray=[6, 5, 3], indices={ 4, 1, 3 }, indexVec={ 2, 1, 0 }, indexArray={ 4, 3, 1 }, indexArrayU32={ 3, 0, 5 }, indicesInto={ 5, 0, 2 }, indicesU32={ 3, 2, 5 }
root weighted no-replacement helpers: weightedIndices={ 0, 2 }, weightedIndexVec={ 1, 2 }, weightedIndexArray={ 2, 1 }, weightedIndexArrayU32={ 1, 2 }, weightedIndicesInto={ 2, 1 }, weightedIndicesU32Into={ 1, 2 }, weightedValues=[green, blue], weightedValuesInto=[red, blue], weightedArray=[red, blue], weightedPtrs=[green, blue], weightedPtrsInto=[blue, red], weightedMutPtrs=[green, blue], weightedMutPtrsInto=[red, blue]
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
toolingcheck ok
readmecheck ok
examplecheck ok
roadmapcheck ok
apicheck ok
```

```text
$ git diff --check
```

## Result

S4-M515 is closed for the current bar: root system-entropy callers can produce
fixed-size no-replacement mutable-pointer arrays without manually constructing a
secure engine. This is API ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
