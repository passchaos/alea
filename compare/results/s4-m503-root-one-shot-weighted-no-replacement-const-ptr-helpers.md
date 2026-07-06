# S4-M503 Root One-Shot Weighted No-Replacement Const-Pointer Helpers

## Gap

S4-M501/S4-M502 added weighted no-replacement value samples and arrays. Borrowed
const-pointer forms still required constructing a secure engine and using
`seq.sampleWeightedPtrs*`.

## API Added

`src/root.zig` now exposes:

- `sampleWeightedPtrs`
- `sampleWeightedPtrsChecked`
- `sampleWeightedPtrArray`
- `sampleWeightedPtrArrayChecked`

Zero-count samples and zero-size arrays return without drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `weightedPtrs` in root no-replacement helper
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
root no-replacement helpers: sample={ 3, 5, 2 }, indices={ 3, 0, 5 }, indicesInto={ 5, 0, 3 }, indicesU32={ 4, 5, 3 }, weightedIndices={ 0, 2 }, weightedValues=[green, blue], weightedArray=[red, blue], weightedPtrs=[green, blue]
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
roadmapcheck ok
apicheck ok
toolingcheck ok
examplecheck ok
```

```text
$ git diff --check
```

## Result

S4-M503 is closed for the current bar: root system-entropy callers can allocate
weighted no-replacement const-pointer samples without manually constructing a
secure engine. This is API ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
