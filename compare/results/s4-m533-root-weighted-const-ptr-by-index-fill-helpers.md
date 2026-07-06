# S4-M533 Root One-Shot Index-Weighted Const-Pointer Fill Helpers

## Gap

S4-M530 added root one-shot index-weighted const-pointer choice, but callers
that wanted to fill a caller-owned buffer with repeated index-weighted const
pointers still had to construct a secure engine manually and call
`seq.fillChooseWeightedConstPtrByIndex*`.

## API Added

`src/root.zig` now exposes:

- `fillChooseWeightedConstPtrByIndex`
- `fillChooseWeightedConstPtrByIndexChecked`

Zero-length destinations return before validating weights or drawing entropy.
All-zero weights fill nullable destinations with `null`; the checked helper
rejects them. Single-positive weights fill deterministically without drawing
entropy. Invalid weights fail before entropy is requested.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byIndexFill=` in root weighted pointer
  helper output.
- `tools/examplecheck.zig` guards that pointer example token.
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

Runnable example excerpt showing the guarded by-index const-pointer fill token:

```text
$ zig build run-basic | grep "root weighted pointer helpers"
root weighted pointer helpers: ptr=blue, byIndexPtr=red, byIndexFill=[green, blue, green, blue], ptrArray=[blue, blue, red, blue], ptrBatch=[blue, blue, blue, blue]
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
examplecheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M533 is closed for the current bar: root system-entropy callers can fill
caller-owned const-pointer buffers from an item slice and comptime index-weight
function without manually constructing a secure engine. This is API ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
