# S4-M509 Root One-Shot Weighted No-Replacement Index Array Helpers

## Gap

S4-M500/S4-M505 added allocation-returning and caller-owned root weighted
no-replacement index samples. Fixed-size usize/u32 index arrays still required
constructing a secure engine and using `seq.sampleWeightedIndexArray*` directly.

## API Added

`src/root.zig` now exposes:

- `sampleWeightedIndexArray`
- `sampleWeightedIndexArrayChecked`
- `sampleWeightedIndexArrayU32`
- `sampleWeightedIndexArrayU32Checked`

Zero-size arrays return without drawing entropy. All-zero weights,
single-positive singleton arrays, oversized checked requests, and invalid
weights are handled before entropy is requested when the result or error is
deterministic.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `weightedIndexArray` and
  `weightedIndexArrayU32` in root no-replacement helper output.
- `tools/examplecheck.zig` guards those example tokens.
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
root no-replacement helpers: sample={ 5, 4, 1 }, indices={ 3, 2, 0 }, indicesInto={ 2, 4, 1 }, indicesU32={ 5, 3, 2 }, weightedIndices={ 0, 2 }, weightedIndexArray={ 2, 1 }, weightedIndexArrayU32={ 1, 2 }, weightedIndicesInto={ 1, 0 }, weightedIndicesU32Into={ 1, 2 }, weightedValues=[green, blue], weightedValuesInto=[red, blue], weightedArray=[blue, green], weightedPtrs=[red, blue], weightedPtrsInto=[green, blue], weightedMutPtrs=[green, blue], weightedMutPtrsInto=[green, blue]
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
roadmapcheck ok
toolingcheck ok
readmecheck ok
apicheck ok
examplecheck ok
```

```text
$ git diff --check
```

## Result

S4-M509 is closed for the current bar: root system-entropy callers can produce
fixed-size weighted no-replacement usize/u32 index arrays without manually
constructing a secure engine. This is API ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
