# S4-M511 Root One-Shot Weighted No-Replacement Compact IndexVec Helpers

## Gap

S4-M500/S4-M505/S4-M509 added allocation-returning, caller-owned, and fixed-size
root weighted no-replacement index samples. Compact `IndexVec` weighted samples
still required constructing a secure engine and using `seq.sampleWeightedIndexVec*`
directly.

## API Added

`src/root.zig` now exposes:

- `sampleWeightedIndexVec`
- `sampleWeightedIndexVecChecked`

Zero-count samples return without drawing entropy. All-zero weights,
single-positive samples, oversized checked requests, and invalid weights are
validated before entropy is requested when the result or error is deterministic.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `weightedIndexVec` in root no-replacement
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
root no-replacement helpers: sample={ 4, 6, 1 }, indices={ 1, 0, 4 }, indexVec={ 1, 2, 3 }, indicesInto={ 1, 4, 0 }, indicesU32={ 3, 0, 2 }, weightedIndices={ 1, 2 }, weightedIndexVec={ 1, 2 }, weightedIndexArray={ 1, 2 }, weightedIndexArrayU32={ 1, 2 }, weightedIndicesInto={ 1, 2 }, weightedIndicesU32Into={ 2, 1 }, weightedValues=[green, blue], weightedValuesInto=[green, blue], weightedArray=[green, blue], weightedPtrs=[green, red], weightedPtrsInto=[blue, red], weightedMutPtrs=[red, blue], weightedMutPtrsInto=[green, blue]
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
apicheck ok
roadmapcheck ok
examplecheck ok
toolingcheck ok
```

```text
$ git diff --check
```

## Result

S4-M511 is closed for the current bar: root system-entropy callers can allocate
compact weighted no-replacement `IndexVec` samples without manually constructing
a secure engine. This is API ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
