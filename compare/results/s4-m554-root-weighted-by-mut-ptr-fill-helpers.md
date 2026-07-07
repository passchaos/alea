# S4-M554 Root Item-Accessor Weighted Mutable-Pointer Fill Helpers

## Gap

S4-M551 added root item-accessor weighted mutable-pointer one-shot helpers, but
callers that wanted to fill caller-owned buffers with repeated weighted `*T`
values from item-local weights still had to construct a secure engine manually
and call `seq.fillChooseWeightedPtrBy*`.

## API Added

`src/root.zig` now exposes:

- `fillChooseWeightedPtrBy`
- `fillChooseWeightedPtrByChecked`

Zero-length destinations return before validating weights or drawing entropy.
All-zero item weights fill nullable destinations with `null`; the checked helper
rejects them with `error.EmptyInput`. Single-positive item weights fill mutable
pointers deterministically before entropy is requested. Invalid weights fail
before entropy is requested. Multi-positive item weights construct an explicit
root secure engine and defer filling to `seq.fillChooseWeightedPtrBy*`.
Deterministic tests also write through one returned pointer to verify callers
receive mutable borrows into the original slice.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byPtrFill=` in the root weighted mutable
  pointer helper output using a mutable slice of structs plus an item-weight
  accessor.
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

Runnable example excerpt showing the guarded item-accessor mutable-pointer fill token:

```text
$ zig build run-basic | grep "root weighted mutable pointer helpers"
root weighted mutable pointer helpers: ptr=blue, byPtr=blue, byPtrFill=[blue, blue, blue, green], byIndexPtr=blue, byIndexFill=[red, blue, blue, blue], byIndexBatch=[blue, green, red, green], byIndexArray=[blue, blue, red, blue], ptrArray=[blue, red, green, blue], ptrBatch=[blue, green, green, blue]
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
examplecheck ok
roadmapcheck ok
```

## Result

S4-M554 is closed for the current bar: root system-entropy callers can fill
caller-owned weighted mutable-pointer buffers directly from a mutable item slice
and comptime item-weight accessor without manually constructing a secure engine
or parallel weight slice. This is API ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
