# S4-M513 Root One-Shot No-Replacement Fixed-Size Value Array Helpers

## Gap

S4-M512 added root fixed-size no-replacement index arrays, while fixed-size
no-replacement value arrays still required constructing a secure engine and using
`seq.sampleItemsArray*` directly.

## API Added

`src/root.zig` now exposes:

- `sampleItemsArray`
- `sampleItemsArrayChecked`

Zero-size arrays and all-item arrays return without drawing entropy. The checked
helper rejects oversized requests before entropy is requested.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `sampleArray` in root no-replacement helper
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
root no-replacement helpers: sample={ 2, 5, 6 }, sampleArray={ 3, 4, 5 }, indices={ 1, 0, 3 }, indexVec={ 2, 3, 4 }, indexArray={ 2, 4, 3 }, indexArrayU32={ 2, 0, 5 }, indicesInto={ 4, 1, 5 }, indicesU32={ 1, 5, 3 }, weightedIndices={ 2, 0 }, weightedIndexVec={ 2, 0 }, weightedIndexArray={ 1, 2 }, weightedIndexArrayU32={ 0, 2 }, weightedIndicesInto={ 1, 2 }, weightedIndicesU32Into={ 1, 2 }, weightedValues=[green, blue], weightedValuesInto=[red, blue], weightedArray=[red, blue], weightedPtrs=[red, blue], weightedPtrsInto=[blue, green], weightedMutPtrs=[green, blue], weightedMutPtrsInto=[blue, red]
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
readmecheck ok
examplecheck ok
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M513 is closed for the current bar: root system-entropy callers can produce
fixed-size no-replacement value arrays without manually constructing a secure
engine. This is API ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
