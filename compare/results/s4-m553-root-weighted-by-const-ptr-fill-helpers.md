# S4-M553 Root Item-Accessor Weighted Const-Pointer Fill Helpers

## Gap

S4-M550 added root item-accessor weighted const-pointer one-shot helpers, but
callers that wanted to fill caller-owned buffers with repeated weighted
`*const T` values from item-local weights still had to construct a secure engine
manually and call `seq.fillChooseWeightedConstPtrBy*`.

## API Added

`src/root.zig` now exposes:

- `fillChooseWeightedConstPtrBy`
- `fillChooseWeightedConstPtrByChecked`

Zero-length destinations return before validating weights or drawing entropy.
All-zero item weights fill nullable destinations with `null`; the checked helper
rejects them with `error.EmptyInput`. Single-positive item weights fill pointers
deterministically before entropy is requested. Invalid weights fail before
entropy is requested. Multi-positive item weights construct an explicit root
secure engine and defer filling to `seq.fillChooseWeightedConstPtrBy*`.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byPtrFill=` in the root weighted pointer
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

Runnable example excerpt showing the guarded item-accessor const-pointer fill token:

```text
$ zig build run-basic | grep "root weighted pointer helpers"
root weighted pointer helpers: ptr=red, byPtr=blue, byPtrFill=[blue, blue, blue, blue], byIndexPtr=blue, byIndexFill=[blue, blue, blue, blue], byIndexBatch=[blue, green, blue, green], byIndexArray=[blue, green, red, green], ptrArray=[blue, green, red, red], ptrBatch=[blue, blue, green, blue]
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
toolingcheck ok
roadmapcheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M553 is closed for the current bar: root system-entropy callers can fill
caller-owned weighted const-pointer buffers directly from an item slice and
comptime item-weight accessor without manually constructing a secure engine or
parallel weight slice. This is API ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
