# S4-M551 Root Item-Accessor Weighted Mutable-Pointer Choice Helpers

## Gap

S4-M550 added root item-accessor weighted const-pointer choice helpers, but
callers that wanted a writable borrowed value (`*T`) from a mutable item slice
plus comptime item-weight accessor still had to construct a secure engine
manually and call `seq.chooseWeightedPtrBy*`.

## API Added

`src/root.zig` now exposes:

- `chooseWeightedPtrBy`
- `chooseWeightedPtrByChecked`

The nullable helper returns `null` for empty or all-zero item weights. The
checked helper returns `error.EmptyInput` for empty or all-zero item weights.
Single-positive item weights return a mutable pointer to the corresponding item
deterministically before entropy is requested. Invalid weights fail before
entropy is requested. Multi-positive item weights use the root secure engine via
`weightedIndexBy`. Deterministic tests also write through the returned pointer to
verify callers receive a mutable borrow into the original slice.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byPtr=` in the root weighted mutable-pointer
  helper output using a mutable slice of structs plus an item-weight accessor.
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

Runnable example excerpt showing the guarded item-accessor mutable-pointer token:

```text
$ zig build run-basic | grep "root weighted mutable pointer helpers"
root weighted mutable pointer helpers: ptr=green, byPtr=blue, byIndexPtr=red, byIndexFill=[red, red, green, blue], byIndexBatch=[red, green, blue, blue], byIndexArray=[blue, red, blue, green], ptrArray=[blue, blue, blue, blue], ptrBatch=[blue, blue, blue, blue]
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
readmecheck ok
apicheck ok
roadmapcheck ok
examplecheck ok
```

## Result

S4-M551 is closed for the current bar: root system-entropy callers can choose a
weighted mutable pointer directly from a mutable item slice and comptime
item-weight accessor without manually constructing a secure engine or parallel
weight slice. This is API ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
