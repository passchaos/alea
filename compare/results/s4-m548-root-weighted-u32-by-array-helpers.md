# S4-M548 Root Item-Accessor Weighted U32 Index Array Helpers

## Gap

S4-M547 added root item-accessor weighted `usize` index array helpers, but
stack-friendly compact `u32` arrays still required constructing a secure engine
manually and calling `seq.weightedIndexU32ArrayBy*` when weights lived on the
items.

## API Added

`src/root.zig` now exposes:

- `weightedIndexU32ArrayBy`
- `weightedIndexU32ArrayByChecked`

Zero-size arrays return before validating weights or drawing entropy. Oversized
item slices fail with `error.InvalidParameter`. All-zero item weights return
`null` for the nullable helper; the checked helper rejects them with
`error.EmptyInput`. Single-positive item weights fill compact indices
deterministically before entropy is requested. Invalid weights fail before
entropy is requested. Multi-positive item weights construct an explicit root
secure engine and defer sampling to `seq.weightedIndexU32ArrayBy*`.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `arrayU32By=` in the root weighted helper
  output using a slice of structs plus an item-weight accessor.
- `tools/examplecheck.zig` guards the new example token.
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

Runnable example excerpt showing the guarded compact item-accessor array token:

```text
$ zig build run-basic | grep "root weighted helpers"
root weighted helpers: weightedIndex=2, weightedIndexU32=0, byIndex=2, by=2, byLabel=blue, byU32=2, byIndexU32=1, fillBy={ 2, 1, 1, 2 }, fillU32By={ 1, 2, 1, 2 }, batchBy={ 0, 2, 1, 0 }, batchU32By={ 2, 0, 2, 1 }, arrayBy={ 2, 2, 2, 2 }, arrayU32By={ 2, 2, 2, 1 }, fillByIndex={ 2, 0, 0, 0 }, fillU32ByIndex={ 2, 2, 1, 2 }, batchByIndex={ 1, 0, 2, 2 }, batchU32ByIndex={ 1, 2, 2, 1 }, arrayByIndex={ 1, 2, 0, 1 }, arrayU32ByIndex={ 0, 0, 2, 2 }, fill={ 2, 2, 2, 2 }, fillU32={ 2, 2, 2, 0 }, array={ 2, 1, 1, 2 }, arrayU32={ 2, 2, 2, 2 }, batch={ 2, 2, 2, 2 }, batchU32={ 1, 1, 1, 2 }
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
roadmapcheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
apicheck ok
```

## Result

S4-M548 is closed for the current bar: root system-entropy callers can produce
fixed-size compact `u32` weighted index arrays directly from an item slice and
comptime item-weight accessor without manually constructing a secure engine or
parallel weight slice. This is API ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
