# S4-M507 Root One-Shot Weighted No-Replacement Caller-Owned Const-Pointer Buffers

## Gap

S4-M503 added allocation-returning root weighted no-replacement const-pointer
samples. Caller-owned const-pointer buffers still required constructing a secure
engine and using `seq.sampleWeightedPtrsInto*` directly.

## API Added

`src/root.zig` now exposes:

- `sampleWeightedPtrsInto`
- `sampleWeightedPtrsIntoChecked`

Zero-output buffers return without drawing entropy. Length mismatch, scratch
length errors, oversized checked requests, all-zero weights, and single-positive
weights are validated before entropy is requested when the result is
deterministic.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `weightedPtrsInto` in root no-replacement
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
root no-replacement helpers: sample={ 3, 2, 4 }, indices={ 2, 5, 0 }, indicesInto={ 0, 4, 3 }, indicesU32={ 4, 1, 0 }, weightedIndices={ 1, 2 }, weightedIndicesInto={ 1, 2 }, weightedIndicesU32Into={ 1, 2 }, weightedValues=[green, blue], weightedValuesInto=[green, blue], weightedArray=[red, blue], weightedPtrs=[green, blue], weightedPtrsInto=[green, blue], weightedMutPtrs=[blue, red]
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
examplecheck ok
readmecheck ok
toolingcheck ok
apicheck ok
```

```text
$ git diff --check
```

## Result

S4-M507 is closed for the current bar: root system-entropy callers can fill
caller-owned weighted no-replacement const-pointer buffers without manually
constructing a secure engine. This is API ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
