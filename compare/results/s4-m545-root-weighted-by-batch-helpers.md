# S4-M545 Root Item-Accessor Weighted Index Batch Helpers

## Gap

S4-M543 added root item-accessor weighted `usize` fill helpers, but callers that
wanted allocation-returning repeated `usize` weighted index batches from
item-local weights still had to allocate a destination and call a fill helper, or
construct a secure engine manually and call `seq.weightedIndexBatchBy*`.

## API Added

`src/root.zig` now exposes:

- `weightedIndexBatchBy`
- `weightedIndexBatchByChecked`

Zero-count batches allocate and return an empty slice before validating weights
or drawing entropy. All-zero item weights fill nullable batches with `null`; the
checked helper rejects them with `error.EmptyInput`. Single-positive item
weights fill deterministically before entropy is requested. Invalid weights fail
before entropy is requested. Multi-positive item weights use the root secure
engine via the item-accessor fill helpers.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `batchBy=` in the root weighted helper
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

Runnable example excerpt showing the guarded item-accessor batch token:

```text
$ zig build run-basic | grep "root weighted helpers"
root weighted helpers: weightedIndex=2, weightedIndexU32=2, byIndex=0, by=1, byLabel=green, byU32=2, byIndexU32=2, fillBy={ 2, 2, 0, 2 }, fillU32By={ 2, 2, 2, 1 }, batchBy={ 2, 2, 2, 2 }, fillByIndex={ 2, 1, 0, 2 }, fillU32ByIndex={ 2, 1, 2, 2 }, batchByIndex={ 0, 2, 0, 2 }, batchU32ByIndex={ 2, 1, 2, 2 }, arrayByIndex={ 2, 1, 2, 1 }, arrayU32ByIndex={ 2, 2, 1, 1 }, fill={ 2, 2, 2, 2 }, fillU32={ 2, 2, 2, 0 }, array={ 2, 2, 0, 2 }, arrayU32={ 2, 2, 2, 2 }, batch={ 2, 2, 2, 1 }, batchU32={ 1, 2, 2, 2 }
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
toolingcheck ok
examplecheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M545 is closed for the current bar: root system-entropy callers can allocate
repeated `usize` weighted index batches directly from an item slice and comptime
item-weight accessor without manually constructing a secure engine or parallel
weight slice. This is API ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
