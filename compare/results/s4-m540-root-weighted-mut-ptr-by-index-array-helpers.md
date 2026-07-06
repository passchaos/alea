# S4-M540 Root One-Shot Index-Weighted Mutable-Pointer Array Helpers

## Gap

S4-M537 added root allocation-returning index-weighted mutable-pointer batches,
but callers that wanted stack-friendly fixed-size repeated mutable-pointer arrays
from a mutable item slice plus comptime index-weight function still had to
construct a secure engine manually and call `seq.chooseWeightedPtrArrayByIndex*`.

## API Added

`src/root.zig` now exposes:

- `chooseWeightedPtrArrayByIndex`
- `chooseWeightedPtrArrayByIndexChecked`

Zero-size arrays return before validating weights or drawing entropy. All-zero
weights return `null` for the nullable helper; the checked helper rejects them.
Single-positive weights fill deterministically without drawing entropy. Invalid
weights fail before entropy is requested. Deterministic unit coverage also writes
through one returned pointer to verify callers receive mutable pointers into the
original slice.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byIndexArray=` in root weighted mutable
  pointer helper output.
- `tools/examplecheck.zig` guards that mutable-pointer array example token.
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

Runnable example excerpt showing the guarded by-index mutable-pointer array token:

```text
$ zig build run-basic | grep "root weighted mutable pointer helpers"
root weighted mutable pointer helpers: ptr=red, byIndexPtr=blue, byIndexFill=[blue, green, blue, green], byIndexBatch=[blue, green, green, blue], byIndexArray=[green, blue, green, blue], ptrArray=[blue, green, red, green], ptrBatch=[blue, blue, blue, red]
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
examplecheck ok
apicheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M540 is closed for the current bar: root system-entropy callers can produce
fixed-size mutable-pointer arrays from a mutable item slice and comptime
index-weight function without manually constructing a secure engine. This is API
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
