# S4-M537 Root One-Shot Index-Weighted Mutable-Pointer Batch Helpers

## Gap

S4-M534 added root caller-owned index-weighted mutable-pointer fills, but callers
that wanted an allocation-returning repeated mutable-pointer batch from a
mutable item slice plus comptime index-weight function still had to construct a
secure engine manually and call `seq.chooseWeightedPtrBatchByIndex*`.

## API Added

`src/root.zig` now exposes:

- `chooseWeightedPtrBatchByIndex`
- `chooseWeightedPtrBatchByIndexChecked`

Zero-count batches allocate and return an empty slice before validating weights
or drawing entropy. All-zero weights fill nullable batches with `null`; the
checked helper rejects them. Single-positive weights fill deterministically
without drawing entropy. Invalid weights fail before entropy is requested.
Deterministic unit coverage also writes through one returned pointer to verify
callers receive mutable pointers into the original slice.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byIndexBatch=` in root weighted mutable
  pointer helper output.
- `tools/examplecheck.zig` guards that mutable-pointer batch example token.
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

Runnable example excerpt showing the guarded by-index mutable-pointer batch token:

```text
$ zig build run-basic | grep "root weighted mutable pointer helpers"
root weighted mutable pointer helpers: ptr=blue, byIndexPtr=green, byIndexFill=[blue, green, blue, green], byIndexBatch=[green, blue, blue, blue], ptrArray=[blue, blue, blue, blue], ptrBatch=[blue, blue, blue, green]
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
examplecheck ok
roadmapcheck ok
apicheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M537 is closed for the current bar: root system-entropy callers can allocate
mutable-pointer batches from a mutable item slice and comptime index-weight
function without manually constructing a secure engine. This is API ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
