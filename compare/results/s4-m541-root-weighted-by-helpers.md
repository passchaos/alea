# S4-M541 Root Item-Accessor Weighted Index Helpers

## Gap

Rust `rand` exposes slice `choose_weighted` ergonomics that accept a per-item
weight accessor (see local `~/Work/rand/src/seq/slice.rs`). Alea already had
`seq.weightedIndexBy*` and root index-weighted helpers, but callers that wanted
a root-level system-entropy weighted **index** from an item slice and comptime
item-weight accessor still had to construct a secure engine manually or maintain
a separate weight slice.

## API Added

`src/root.zig` now exposes:

- `weightedIndexBy`
- `weightedIndexByChecked`

The nullable helper returns `null` for empty or all-zero item weights. The
checked helper returns `error.EmptyInput` for empty or all-zero item weights.
Single-positive item weights return the corresponding index deterministically
before entropy is requested. Invalid weights fail before entropy is requested.
Multi-positive item weights construct an explicit root secure engine and defer
sampling to `seq.weightedIndexBy`.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `by=` and `byLabel=` in the root weighted
  helper output using a slice of structs plus an item-weight accessor.
- `tools/examplecheck.zig` guards the new example tokens.
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

Runnable example excerpt showing the guarded item-accessor tokens:

```text
$ zig build run-basic | grep "root weighted helpers"
root weighted helpers: weightedIndex=1, weightedIndexU32=2, byIndex=2, by=2, byLabel=blue, byIndexU32=2, fillByIndex={ 0, 2, 1, 0 }, fillU32ByIndex={ 2, 1, 2, 0 }, batchByIndex={ 1, 2, 1, 1 }, batchU32ByIndex={ 2, 2, 0, 1 }, arrayByIndex={ 1, 2, 0, 1 }, arrayU32ByIndex={ 1, 1, 1, 0 }, fill={ 2, 2, 1, 2 }, fillU32={ 2, 1, 1, 2 }, array={ 1, 2, 2, 2 }, arrayU32={ 2, 2, 0, 2 }, batch={ 1, 2, 2, 2 }, batchU32={ 0, 2, 2, 2 }
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
examplecheck ok
roadmapcheck ok
apicheck ok
toolingcheck ok
```

## Result

S4-M541 is closed for the current bar: root system-entropy callers can sample
weighted indices directly from an item slice and comptime item-weight accessor
without manually constructing a secure engine or parallel weight slice. This is
API ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
