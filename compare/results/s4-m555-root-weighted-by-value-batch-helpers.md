# S4-M555 Root Item-Accessor Weighted Value Batch Helpers

## Gap

S4-M552 added root item-accessor weighted value fill helpers, but callers that
wanted allocation-returning repeated weighted values from item-local weights
still had to allocate a destination and call a fill helper, or construct a secure
engine manually and call `seq.chooseWeightedBatchBy*`.

## API Added

`src/root.zig` now exposes:

- `chooseWeightedBatchBy`
- `chooseWeightedBatchByChecked`

Zero-count batches allocate and return an empty slice before validating weights
or drawing entropy. All-zero item weights fill nullable batches with `null`; the
checked helper rejects them with `error.EmptyInput`. Single-positive item weights
fill deterministically before entropy is requested. Invalid weights fail before
entropy is requested. Multi-positive item weights use the root secure engine via
the item-accessor fill helpers.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byBatch=` in the root weighted value helper
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

Runnable example excerpt showing the guarded item-accessor value batch token:

```text
$ zig build run-basic | grep "root weighted value helpers"
root weighted value helpers: value=green, byValue=blue, byFill=[blue, blue, green, blue], byBatch=[red, green, blue, red], byIndexValue=blue, byIndexFill=[blue, blue, green, green], byIndexBatch=[green, green, blue, blue], byIndexArray=[red, red, blue, blue]
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
readmecheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M555 is closed for the current bar: root system-entropy callers can allocate
repeated weighted value batches directly from an item slice and comptime
item-weight accessor without manually constructing a secure engine or parallel
weight slice. This is API ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
