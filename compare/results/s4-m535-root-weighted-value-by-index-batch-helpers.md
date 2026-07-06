# S4-M535 Root One-Shot Index-Weighted Value Batch Helpers

## Gap

S4-M532 added root caller-owned index-weighted value fills, but callers that
wanted an allocation-returning repeated value batch from an item slice plus
comptime index-weight function still had to construct a secure engine manually
and call `seq.chooseWeightedBatchByIndex*`.

## API Added

`src/root.zig` now exposes:

- `chooseWeightedBatchByIndex`
- `chooseWeightedBatchByIndexChecked`

Zero-count batches allocate and return an empty slice before validating weights
or drawing entropy. All-zero weights fill nullable batches with `null`; the
checked helper rejects them. Single-positive weights fill deterministically
without drawing entropy. Invalid weights fail before entropy is requested.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byIndexBatch=` in root weighted value
  helper output.
- `tools/examplecheck.zig` guards that value-batch example token.
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

Runnable example excerpt showing the guarded by-index value-batch token:

```text
$ zig build run-basic | grep "root weighted value helpers"
root weighted value helpers: value=blue, byIndexValue=green, byIndexFill=[green, blue, blue, green], byIndexBatch=[blue, blue, blue, blue], fill=[blue, blue, blue, blue], array=[blue, blue, green, green], batch=[blue, green, red, blue]
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
apicheck ok
examplecheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M535 is closed for the current bar: root system-entropy callers can allocate
value batches from an item slice and comptime index-weight function without
manually constructing a secure engine. This is API ergonomics work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
