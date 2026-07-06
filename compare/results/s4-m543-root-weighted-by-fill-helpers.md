# S4-M543 Root Item-Accessor Weighted Index Fill Helpers

## Gap

S4-M541 and S4-M542 added root one-shot item-accessor weighted index helpers,
but callers that wanted to fill a caller-owned buffer of repeated `usize`
weighted indices from item-local weights still had to construct a secure engine
manually and call `seq.fillWeightedIndexBy*`.

## API Added

`src/root.zig` now exposes:

- `fillWeightedIndexBy`
- `fillWeightedIndexByChecked`

Zero-length destinations return before validating weights or drawing entropy.
All-zero item weights fill nullable destinations with `null`; the checked helper
rejects them with `error.EmptyInput`. Single-positive item weights fill
deterministically before entropy is requested. Invalid weights fail before
entropy is requested. Multi-positive item weights construct an explicit root
secure engine and defer filling to `seq.fillWeightedIndexBy*`.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `fillBy=` in the root weighted helper output
  using a slice of structs plus an item-weight accessor.
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

Runnable example excerpt showing the guarded item-accessor fill token:

```text
$ zig build run-basic | grep "root weighted helpers"
root weighted helpers: weightedIndex=0, weightedIndexU32=2, byIndex=1, by=1, byLabel=green, byU32=0, byIndexU32=2, fillBy={ 2, 2, 2, 0 }, fillByIndex={ 1, 2, 2, 1 }, fillU32ByIndex={ 2, 1, 2, 1 }, batchByIndex={ 0, 2, 2, 1 }, batchU32ByIndex={ 0, 2, 1, 2 }, arrayByIndex={ 1, 2, 0, 0 }, arrayU32ByIndex={ 2, 2, 2, 0 }, fill={ 2, 2, 2, 1 }, fillU32={ 0, 2, 1, 2 }, array={ 1, 1, 1, 1 }, arrayU32={ 2, 1, 2, 2 }, batch={ 0, 2, 2, 2 }, batchU32={ 2, 0, 2, 2 }
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
examplecheck ok
readmecheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M543 is closed for the current bar: root system-entropy callers can fill
caller-owned repeated weighted index buffers directly from an item slice and
comptime item-weight accessor without manually constructing a secure engine or
parallel weight slice. This is API ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
