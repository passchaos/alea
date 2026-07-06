# S4-M539 Root One-Shot Index-Weighted Const-Pointer Array Helpers

## Gap

S4-M536 added root allocation-returning index-weighted const-pointer batches,
but callers that wanted stack-friendly fixed-size repeated const-pointer arrays
from an item slice plus comptime index-weight function still had to construct a
secure engine manually and call `seq.chooseWeightedConstPtrArrayByIndex*`.

## API Added

`src/root.zig` now exposes:

- `chooseWeightedConstPtrArrayByIndex`
- `chooseWeightedConstPtrArrayByIndexChecked`

Zero-size arrays return before validating weights or drawing entropy. All-zero
weights return `null` for the nullable helper; the checked helper rejects them.
Single-positive weights fill deterministically without drawing entropy. Invalid
weights fail before entropy is requested.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byIndexArray=` in root weighted pointer
  helper output.
- `tools/examplecheck.zig` guards that const-pointer array example token.
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

Runnable example excerpt showing the guarded by-index const-pointer array token:

```text
$ zig build run-basic | grep "root weighted pointer helpers"
root weighted pointer helpers: ptr=blue, byIndexPtr=blue, byIndexFill=[blue, green, blue, blue], byIndexBatch=[green, blue, blue, blue], byIndexArray=[green, blue, green, blue], ptrArray=[blue, blue, blue, green], ptrBatch=[blue, green, blue, blue]
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
readmecheck ok
roadmapcheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M539 is closed for the current bar: root system-entropy callers can produce
fixed-size const-pointer arrays from an item slice and comptime index-weight
function without manually constructing a secure engine. This is API ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
