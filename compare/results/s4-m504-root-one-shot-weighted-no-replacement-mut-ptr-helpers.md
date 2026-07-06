# S4-M504 Root One-Shot Weighted No-Replacement Mutable-Pointer Helpers

## Gap

S4-M503 added weighted no-replacement const-pointer samples. Mutable-pointer
forms still required constructing a secure engine and using
`seq.sampleWeightedMutPtrs*`.

## API Added

`src/root.zig` now exposes:

- `sampleWeightedMutPtrs`
- `sampleWeightedMutPtrsChecked`
- `sampleWeightedMutPtrArray`
- `sampleWeightedMutPtrArrayChecked`

Zero-count samples and zero-size arrays return without drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `weightedMutPtrs` in root no-replacement
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
root no-replacement helpers: sample={ 5, 6, 3 }, indices={ 1, 2, 0 }, indicesInto={ 3, 5, 1 }, indicesU32={ 5, 0, 4 }, weightedIndices={ 1, 2 }, weightedValues=[blue, green], weightedArray=[red, blue], weightedPtrs=[blue, green], weightedMutPtrs=[green, blue]
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

S4-M504 is closed for the current bar: root system-entropy callers can allocate
weighted no-replacement mutable-pointer samples without manually constructing a
secure engine. This is API ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
