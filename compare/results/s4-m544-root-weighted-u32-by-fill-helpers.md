# S4-M544 Root Item-Accessor Weighted U32 Index Fill Helpers

## Gap

S4-M543 added root item-accessor weighted `usize` index fill helpers, but compact
`u32` destination buffers still required constructing a secure engine manually
and calling `seq.fillWeightedIndexU32By*` when weights lived on the items
instead of in a parallel weight slice.

## API Added

`src/root.zig` now exposes:

- `fillWeightedIndexU32By`
- `fillWeightedIndexU32ByChecked`

Oversized item slices fail with `error.InvalidParameter` before scanning weights
or drawing entropy. Zero-length destinations return before validating weights or
drawing entropy. All-zero item weights fill nullable destinations with `null`;
the checked helper rejects them with `error.EmptyInput`. Single-positive item
weights fill compact indices deterministically before entropy is requested.
Invalid weights fail before entropy is requested. Multi-positive item weights
construct an explicit root secure engine and defer filling to
`seq.fillWeightedIndexU32By*`.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `fillU32By=` in the root weighted helper
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

Runnable example excerpt showing the guarded compact item-accessor fill token:

```text
$ zig build run-basic | grep "root weighted helpers"
root weighted helpers: weightedIndex=0, weightedIndexU32=2, byIndex=1, by=2, byLabel=blue, byU32=2, byIndexU32=1, fillBy={ 2, 2, 2, 2 }, fillU32By={ 2, 2, 1, 2 }, fillByIndex={ 1, 2, 0, 2 }, fillU32ByIndex={ 0, 2, 0, 1 }, batchByIndex={ 2, 2, 1, 2 }, batchU32ByIndex={ 2, 2, 1, 2 }, arrayByIndex={ 1, 1, 1, 0 }, arrayU32ByIndex={ 2, 2, 2, 2 }, fill={ 2, 2, 2, 2 }, fillU32={ 1, 0, 2, 2 }, array={ 2, 1, 2, 2 }, arrayU32={ 1, 2, 2, 2 }, batch={ 2, 2, 1, 1 }, batchU32={ 2, 0, 1, 2 }
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
apicheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M544 is closed for the current bar: root system-entropy callers can fill
caller-owned compact `u32` weighted index buffers directly from an item slice and
comptime item-weight accessor without manually constructing a secure engine or
parallel weight slice. This is API ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
