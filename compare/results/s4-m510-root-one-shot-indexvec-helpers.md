# S4-M510 Root One-Shot Compact IndexVec Helpers

## Gap

`seq.sampleIndexVec*` already provided compact no-replacement index-vector
sampling, but root system-entropy callers still had to construct a secure engine
before getting a compact `IndexVec` sample.

## API Added

`src/root.zig` now exposes:

- `IndexVec`
- `sampleIndexVec`
- `sampleIndexVecChecked`

Zero-count samples and small all-index samples return without drawing entropy.
The checked helper rejects oversized requests before entropy is requested.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `indexVec` in root no-replacement helper
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
root no-replacement helpers: sample={ 5, 3, 2 }, indices={ 1, 4, 0 }, indexVec={ 5, 1, 2 }, indicesInto={ 4, 3, 5 }, indicesU32={ 3, 1, 2 }, weightedIndices={ 2, 1 }, weightedIndexArray={ 1, 2 }, weightedIndexArrayU32={ 0, 2 }, weightedIndicesInto={ 2, 1 }, weightedIndicesU32Into={ 2, 0 }, weightedValues=[red, blue], weightedValuesInto=[red, blue], weightedArray=[green, blue], weightedPtrs=[green, blue], weightedPtrsInto=[green, blue], weightedMutPtrs=[green, blue], weightedMutPtrsInto=[green, blue]
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
apicheck ok
examplecheck ok
readmecheck ok
toolingcheck ok
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M510 is closed for the current bar: root system-entropy callers can allocate
compact `IndexVec` no-replacement samples without manually constructing a secure
engine. This is API ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
