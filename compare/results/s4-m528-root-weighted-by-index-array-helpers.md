# S4-M528 Root One-Shot Index-Weighted Array Helpers

## Gap

S4-M525 through S4-M527 added root one-shot index-weighted single-index,
caller-owned fill, and allocation-returning batch helpers from a length plus
comptime index-weight function. Fixed-size stack-friendly arrays for the same
workflow still required manually constructing a secure engine and calling
`seq.weightedIndexArrayByIndex*` / `seq.weightedIndexU32ArrayByIndex*`.

## API Added

`src/root.zig` now exposes:

- `weightedIndexArrayByIndex`
- `weightedIndexArrayByIndexChecked`
- `weightedIndexU32ArrayByIndex`
- `weightedIndexU32ArrayByIndexChecked`

Zero-size arrays return before validation/entropy. All-zero weights return
`null` for nullable arrays and checked arrays reject them. Single-positive
weights fill deterministically without drawing entropy. Invalid weights and
oversized `u32` requests fail before entropy is requested.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `arrayByIndex=` and `arrayU32ByIndex=` in
  root weighted helper output.
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

Runnable example excerpt showing the guarded by-index array tokens:

```text
$ zig build run-basic
root weighted helpers: weightedIndex=2, weightedIndexU32=2, byIndex=2, byIndexU32=1, fillByIndex={ 1, 1, 1, 2 }, fillU32ByIndex={ 2, 2, 2, 0 }, batchByIndex={ 2, 2, 1, 1 }, batchU32ByIndex={ 2, 2, 0, 2 }, arrayByIndex={ 0, 1, 1, 0 }, arrayU32ByIndex={ 1, 2, 0, 2 }, fill={ 1, 0, 2, 1 }, fillU32={ 2, 1, 2, 2 }, array={ 2, 1, 0, 2 }, arrayU32={ 2, 2, 2, 0 }, batch={ 2, 2, 1, 2 }, batchU32={ 2, 2, 2, 2 }
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
toolingcheck ok
roadmapcheck ok
readmecheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M528 is closed for the current bar: root system-entropy callers can produce
fixed-size `usize` or `u32` weighted index arrays from a length and comptime
index-weight function without manually constructing a secure engine. This is API
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
