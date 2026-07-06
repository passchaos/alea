# S4-M516 Root One-Shot No-Replacement Const-Pointer Sampling Helpers

## Gap

S4-M514 added root fixed-size no-replacement const-pointer arrays. Allocation-
returning no-replacement const-pointer samples still required constructing a
secure engine and using `seq.samplePtrs*` directly.

## API Added

`src/root.zig` now exposes:

- `samplePtrs`
- `samplePtrsChecked`

Zero-count samples and all-item samples return without drawing entropy. The
checked helper rejects oversized requests before entropy is requested.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `samplePtrs` in root no-replacement helper
  output.
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
root no-replacement helpers: sample={ 3, 2, 4 }, sampleArray={ 1, 6, 2 }, samplePtrArray=[4, 5, 2], samplePtrs=[1, 3, 5], sampleMutPtrArray=[1, 4, 2], indices={ 0, 4, 1 }, indexVec={ 0, 3, 2 }, indexArray={ 3, 4, 5 }, indexArrayU32={ 3, 2, 1 }, indicesInto={ 2, 1, 0 }, indicesU32={ 5, 2, 4 }
root weighted no-replacement helpers: weightedIndices={ 1, 2 }, weightedIndexVec={ 1, 2 }, weightedIndexArray={ 1, 2 }, weightedIndexArrayU32={ 1, 2 }, weightedIndicesInto={ 1, 2 }, weightedIndicesU32Into={ 1, 2 }, weightedValues=[green, blue], weightedValuesInto=[red, blue], weightedArray=[blue, green], weightedPtrs=[red, blue], weightedPtrsInto=[red, blue], weightedMutPtrs=[blue, green], weightedMutPtrsInto=[green, blue]
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
apicheck ok
roadmapcheck ok
readmecheck ok
examplecheck ok
```

```text
$ git diff --check
```

## Result

S4-M516 is closed for the current bar: root system-entropy callers can allocate
no-replacement const-pointer samples without manually constructing a secure
engine. This is API ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
