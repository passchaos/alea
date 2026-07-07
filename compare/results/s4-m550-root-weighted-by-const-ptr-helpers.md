# S4-M550 Root Item-Accessor Weighted Const-Pointer Choice Helpers

## Gap

S4-M549 added root item-accessor weighted value choice helpers, but callers that
wanted a borrowed value (`*const T`) from an item slice plus comptime item-weight
accessor still had to construct a secure engine manually and call
`seq.chooseWeightedConstPtrBy*`.

## API Added

`src/root.zig` now exposes:

- `chooseWeightedConstPtrBy`
- `chooseWeightedConstPtrByChecked`

The nullable helper returns `null` for empty or all-zero item weights. The
checked helper returns `error.EmptyInput` for empty or all-zero item weights.
Single-positive item weights return a pointer to the corresponding item
deterministically before entropy is requested. Invalid weights fail before
entropy is requested. Multi-positive item weights use the root secure engine via
`weightedIndexBy`.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byPtr=` in the root weighted pointer helper
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

Runnable example excerpt showing the guarded item-accessor const-pointer token:

```text
$ zig build run-basic | grep "root weighted pointer helpers"
root weighted pointer helpers: ptr=green, byPtr=blue, byIndexPtr=blue, byIndexFill=[green, blue, green, blue], byIndexBatch=[blue, blue, green, blue], byIndexArray=[blue, blue, blue, blue], ptrArray=[blue, green, blue, blue], ptrBatch=[blue, blue, red, green]
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
apicheck ok
roadmapcheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M550 is closed for the current bar: root system-entropy callers can choose a
weighted const pointer directly from an item slice and comptime item-weight
accessor without manually constructing a secure engine or parallel weight slice.
This is API ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
