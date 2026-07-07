# S4-M556 Root Item-Accessor Weighted Const-Pointer Batch Helpers

## Gap

S4-M553 added root item-accessor weighted const-pointer fill helpers, but
callers that wanted allocation-returning repeated weighted `*const T` batches
from item-local weights still had to allocate a destination and call a fill
helper, or construct a secure engine manually and call
`seq.chooseWeightedConstPtrBatchBy*`.

## API Added

`src/root.zig` now exposes:

- `chooseWeightedConstPtrBatchBy`
- `chooseWeightedConstPtrBatchByChecked`

Zero-count batches allocate and return an empty slice before validating weights
or drawing entropy. All-zero item weights fill nullable batches with `null`; the
checked helper rejects them with `error.EmptyInput`. Single-positive item weights
fill pointers deterministically before entropy is requested. Invalid weights
fail before entropy is requested. Multi-positive item weights use the root secure
engine via the item-accessor const-pointer fill helpers.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byPtrBatch=` in the root weighted pointer
  helper output using a slice of structs plus an item-weight accessor.
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

Runnable example excerpt showing the guarded item-accessor const-pointer batch token:

```text
$ zig build run-basic | grep "root weighted pointer helpers"
root weighted pointer helpers: ptr=red, byPtr=blue, byPtrFill=[red, green, blue, green], byPtrBatch=[blue, red, blue, blue], byIndexPtr=blue, byIndexFill=[green, green, blue, red], byIndexBatch=[red, blue, green, green], byIndexArray=[blue, red, blue, green], ptrArray=[blue, green, blue, blue], ptrBatch=[red, blue, blue, blue]
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
roadmapcheck ok
examplecheck ok
```

## Result

S4-M556 is closed for the current bar: root system-entropy callers can allocate
repeated weighted const-pointer batches directly from an item slice and comptime
item-weight accessor without manually constructing a secure engine or parallel
weight slice. This is API ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
