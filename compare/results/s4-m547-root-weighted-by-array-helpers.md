# S4-M547 Root Item-Accessor Weighted Index Array Helpers

## Gap

S4-M545 and S4-M546 added root item-accessor weighted index batch helpers, but
callers that wanted stack-friendly fixed-size repeated `usize` weighted index
arrays from item-local weights still had to construct a secure engine manually
and call `seq.weightedIndexArrayBy*`.

## API Added

`src/root.zig` now exposes:

- `weightedIndexArrayBy`
- `weightedIndexArrayByChecked`

Zero-size arrays return before validating weights or drawing entropy. All-zero
item weights return `null` for the nullable helper; the checked helper rejects
them with `error.EmptyInput`. Single-positive item weights fill deterministically
before entropy is requested. Invalid weights fail before entropy is requested.
Multi-positive item weights construct an explicit root secure engine and defer
sampling to `seq.weightedIndexArrayBy*`.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `arrayBy=` in the root weighted helper
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

Runnable example excerpt showing the guarded item-accessor array token:

```text
$ zig build run-basic | grep "root weighted helpers"
root weighted helpers: weightedIndex=2, weightedIndexU32=2, byIndex=2, by=2, byLabel=blue, byU32=2, byIndexU32=2, fillBy={ 2, 1, 1, 2 }, fillU32By={ 2, 0, 2, 1 }, batchBy={ 2, 0, 1, 0 }, batchU32By={ 0, 1, 2, 2 }, arrayBy={ 2, 2, 2, 2 }, fillByIndex={ 1, 1, 2, 1 }, fillU32ByIndex={ 1, 2, 1, 1 }, batchByIndex={ 1, 0, 2, 1 }, batchU32ByIndex={ 1, 1, 1, 2 }, arrayByIndex={ 2, 2, 2, 2 }, arrayU32ByIndex={ 1, 1, 1, 2 }, fill={ 1, 1, 2, 2 }, fillU32={ 2, 2, 2, 1 }, array={ 2, 2, 0, 2 }, arrayU32={ 1, 2, 2, 1 }, batch={ 2, 2, 2, 2 }, batchU32={ 2, 2, 2, 2 }
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

S4-M547 is closed for the current bar: root system-entropy callers can produce
fixed-size repeated `usize` weighted index arrays directly from an item slice
and comptime item-weight accessor without manually constructing a secure engine
or parallel weight slice. This is API ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
