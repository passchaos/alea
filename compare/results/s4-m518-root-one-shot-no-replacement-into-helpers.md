# S4-M518 Root One-Shot No-Replacement Caller-Owned Buffer Helpers

## Gap

Root one-shot no-replacement APIs covered allocation-returning value, const-
pointer, mutable-pointer samples and fixed-size arrays. Caller-owned
no-replacement value/pointer buffers still required constructing a secure engine
and calling `seq.sampleItemsInto*`, `seq.samplePtrsInto*`, or
`seq.sampleMutPtrsInto*` directly.

## API Added

`src/root.zig` now exposes:

- `sampleItemsInto`
- `sampleItemsIntoChecked`
- `samplePtrsInto`
- `samplePtrsIntoChecked`
- `sampleMutPtrsInto`
- `sampleMutPtrsIntoChecked`

Zero-output samples and all-item samples return without drawing entropy. Scratch
lengths and checked oversized requests are validated before entropy is requested.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `sampleItemsInto`, `samplePtrsInto`, and
  `sampleMutPtrsInto` in root no-replacement helper output.
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

Runnable example excerpt showing the guarded caller-owned tokens:

```text
$ zig build run-basic
root no-replacement helpers: sample={ 1, 5, 4 }, sampleArray={ 2, 5, 3 }, samplePtrArray=[5, 6, 4], samplePtrs=[2, 6, 3], sampleMutPtrArray=[1, 4, 6], sampleMutPtrs=[5, 6, 4], sampleItemsInto={ 3, 1, 2 }, samplePtrsInto=[1, 5, 3], sampleMutPtrsInto=[5, 4, 1], indices={ 2, 1, 0 }, indexVec={ 4, 2, 5 }, indexArray={ 4, 1, 2 }, indexArrayU32={ 0, 2, 5 }, indicesInto={ 0, 3, 4 }, indicesU32={ 5, 4, 2 }
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

```text
$ git diff --check
```

Broader native test gate:

```text
$ zig build test
apicheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M518 is closed for the current bar: root system-entropy callers can fill
caller-owned no-replacement value, const-pointer, and mutable-pointer buffers
without manually constructing a secure engine. This is API ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
