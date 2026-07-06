# S4-M506 Root One-Shot Weighted No-Replacement Caller-Owned Value Buffers

## Gap

S4-M501 added allocation-returning root weighted no-replacement value samples.
Caller-owned value buffers still required constructing a secure engine and using
`seq.sampleWeightedInto*` directly.

## API Added

`src/root.zig` now exposes:

- `sampleWeightedInto`
- `sampleWeightedIntoChecked`

Zero-output buffers return without drawing entropy. Length mismatch, scratch
length errors, oversized checked requests, all-zero weights, and single-positive
weights are validated before entropy is requested when the result is
deterministic.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `weightedValuesInto` in root
  no-replacement helper output.
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
root no-replacement helpers: sample={ 5, 3, 4 }, indices={ 5, 0, 4 }, indicesInto={ 5, 2, 4 }, indicesU32={ 0, 1, 4 }, weightedIndices={ 0, 2 }, weightedIndicesInto={ 0, 2 }, weightedIndicesU32Into={ 1, 2 }, weightedValues=[green, blue], weightedValuesInto=[blue, green], weightedArray=[green, blue], weightedPtrs=[green, blue], weightedMutPtrs=[green, blue]
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
roadmapcheck ok
toolingcheck ok
```

```text
$ git diff --check
```

## Result

S4-M506 is closed for the current bar: root system-entropy callers can fill
caller-owned weighted no-replacement value buffers without manually constructing
a secure engine. This is API ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
