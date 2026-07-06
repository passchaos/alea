# S4-M505 Root One-Shot Weighted No-Replacement Caller-Owned Index Buffers

## Gap

S4-M500 added allocation-returning root weighted no-replacement index samples.
Caller-owned usize/u32 buffers still required constructing a secure engine and
using `seq.sampleWeightedIndices*Into` directly.

## API Added

`src/root.zig` now exposes:

- `sampleWeightedIndicesInto`
- `sampleWeightedIndicesIntoChecked`
- `sampleWeightedIndicesU32Into`
- `sampleWeightedIndicesU32IntoChecked`

Zero-output buffers return without drawing entropy. Scratch length errors,
oversized checked requests, all-zero weights, and single-positive weights are
validated before entropy is requested when the result is deterministic.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `weightedIndicesInto` and
  `weightedIndicesU32Into` in root no-replacement helper output.
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
root no-replacement helpers: sample={ 2, 1, 5 }, indices={ 4, 5, 2 }, indicesInto={ 1, 3, 5 }, indicesU32={ 0, 5, 1 }, weightedIndices={ 0, 2 }, weightedIndicesInto={ 0, 2 }, weightedIndicesU32Into={ 1, 2 }, weightedValues=[blue, green], weightedArray=[blue, red], weightedPtrs=[red, blue], weightedMutPtrs=[red, blue]
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
examplecheck ok
apicheck ok
readmecheck ok
toolingcheck ok
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M505 is closed for the current bar: root system-entropy callers can fill
caller-owned weighted no-replacement usize/u32 index buffers without manually
constructing a secure engine. This is API ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
