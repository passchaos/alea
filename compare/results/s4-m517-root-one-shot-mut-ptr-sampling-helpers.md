# S4-M517 Root One-Shot No-Replacement Mutable-Pointer Sampling Helpers

## Gap

S4-M515 added root fixed-size no-replacement mutable-pointer arrays and S4-M516
added allocation-returning const-pointer samples. Allocation-returning
no-replacement mutable-pointer samples still required constructing a secure
engine and using `seq.sampleMutPtrs*` directly.

## API Added

`src/root.zig` now exposes:

- `sampleMutPtrs`
- `sampleMutPtrsChecked`

Zero-count samples and all-item samples return without drawing entropy. The
checked helper rejects oversized requests before entropy is requested.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `sampleMutPtrs` in root no-replacement
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

Runnable example excerpt showing the guarded `sampleMutPtrs=` token:

```text
$ zig build run-basic
root no-replacement helpers: sample={ 6, 3, 2 }, sampleArray={ 6, 4, 2 }, samplePtrArray=[5, 6, 1], samplePtrs=[1, 4, 6], sampleMutPtrArray=[4, 5, 3], sampleMutPtrs=[4, 5, 1], indices={ 1, 5, 3 }, indexVec={ 1, 3, 0 }, indexArray={ 1, 3, 2 }, indexArrayU32={ 5, 2, 3 }, indicesInto={ 1, 5, 3 }, indicesU32={ 0, 4, 5 }
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
readmecheck ok
roadmapcheck ok
toolingcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M517 is closed for the current bar: root system-entropy callers can allocate
no-replacement mutable-pointer samples without manually constructing a secure
engine. This is API ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
