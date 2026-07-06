# S4-M512 Root One-Shot No-Replacement Index Array Helpers

## Gap

S4-M510 added compact `IndexVec` root sampling, while fixed-size no-replacement
usize/u32 index arrays still required constructing a secure engine and using
`seq.sampleArray*` directly.

## API Added

`src/root.zig` now exposes:

- `sampleArray`
- `sampleArrayChecked`
- `sampleArrayU32`
- `sampleArrayU32Checked`

Zero-size arrays and small all-index arrays return without drawing entropy. The
checked helpers reject oversized requests before entropy is requested.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `indexArray` and `indexArrayU32` in root
  no-replacement helper output.
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
root no-replacement helpers: sample={ 2, 5, 4 }, indices={ 1, 3, 4 }, indexVec={ 2, 5, 3 }, indexArray={ 4, 3, 1 }, indexArrayU32={ 5, 0, 3 }, indicesInto={ 1, 0, 5 }, indicesU32={ 3, 2, 5 }, weightedIndices={ 0, 2 }, weightedIndexVec={ 2, 1 }, weightedIndexArray={ 1, 2 }, weightedIndexArrayU32={ 2, 1 }, weightedIndicesInto={ 1, 2 }, weightedIndicesU32Into={ 2, 1 }, weightedValues=[green, blue], weightedValuesInto=[red, blue], weightedArray=[green, blue], weightedPtrs=[green, blue], weightedPtrsInto=[green, blue], weightedMutPtrs=[blue, green], weightedMutPtrsInto=[red, blue]
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
toolingcheck ok
examplecheck ok
roadmapcheck ok
readmecheck ok
```

```text
$ git diff --check
```

## Result

S4-M512 is closed for the current bar: root system-entropy callers can produce
fixed-size no-replacement usize/u32 index arrays without manually constructing a
secure engine. This is API ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
