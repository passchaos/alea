# S4-M542 Root Item-Accessor Weighted U32 Index Helpers

## Gap

S4-M541 added root item-accessor weighted `usize` index helpers, but compact
`u32` index callers still had to construct a secure engine manually and call
`seq.weightedIndexU32By*` when weights lived on the items themselves. This left
item-accessor one-shot weighted index selection without root-level usize/u32
parity.

## API Added

`src/root.zig` now exposes:

- `weightedIndexU32By`
- `weightedIndexU32ByChecked`

The nullable helper returns `null` for empty or all-zero item weights. The
checked helper returns `error.EmptyInput` for empty or all-zero item weights.
Single-positive item weights return the corresponding compact index
deterministically before entropy is requested. Oversized item slices fail with
`error.InvalidParameter` before scanning weights. Invalid weights fail before
entropy is requested. Multi-positive item weights use the root secure engine via
`weightedIndexBy` and cast the resulting index to `u32`.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byU32=` in the root weighted helper output
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

Runnable example excerpt showing the guarded compact item-accessor token:

```text
$ zig build run-basic | grep "root weighted helpers"
root weighted helpers: weightedIndex=0, weightedIndexU32=0, byIndex=2, by=2, byLabel=blue, byU32=1, byIndexU32=2, fillByIndex={ 2, 1, 2, 2 }, fillU32ByIndex={ 1, 2, 2, 2 }, batchByIndex={ 1, 0, 2, 2 }, batchU32ByIndex={ 1, 0, 1, 0 }, arrayByIndex={ 1, 1, 2, 1 }, arrayU32ByIndex={ 1, 2, 2, 2 }, fill={ 0, 2, 2, 2 }, fillU32={ 2, 2, 2, 1 }, array={ 0, 2, 2, 2 }, arrayU32={ 2, 2, 2, 2 }, batch={ 2, 1, 1, 2 }, batchU32={ 2, 2, 2, 1 }
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
readmecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M542 is closed for the current bar: root system-entropy callers can sample
compact `u32` weighted indices directly from an item slice and comptime
item-weight accessor without manually constructing a secure engine or parallel
weight slice. This is API ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
