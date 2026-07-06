# S4-M531 Root One-Shot Index-Weighted Mutable-Pointer Choice Helpers

## Gap

S4-M530 added root const-pointer choices from an item slice and comptime
index-weight function. Writable borrowed choices for the same index-weighted
workflow still required manually constructing a secure engine and calling
`seq.chooseWeightedPtrByIndex*`.

## API Added

`src/root.zig` now exposes:

- `chooseWeightedPtrByIndex`
- `chooseWeightedPtrByIndexChecked`

Empty/all-zero weights return `null` for the nullable helper; the checked helper
rejects them. Single-positive weights return deterministically without drawing
entropy. Invalid weights fail before entropy is requested. The deterministic
unit coverage also writes through the returned pointer to verify callers receive
a mutable pointer into the original slice.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byIndexPtr=` in root weighted mutable
  pointer helper output.
- `tools/examplecheck.zig` guards that mutable-pointer example token.
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

Runnable example excerpt showing the guarded by-index mutable-pointer token:

```text
$ zig build run-basic | grep "root weighted mutable pointer helpers"
root weighted mutable pointer helpers: ptr=blue, byIndexPtr=blue, ptrArray=[blue, blue, red, red], ptrBatch=[blue, blue, blue, blue]
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
roadmapcheck ok
apicheck ok
toolingcheck ok
readmecheck ok
examplecheck ok
```

## Result

S4-M531 is closed for the current bar: root system-entropy callers can choose
mutable pointers from a mutable item slice and comptime index-weight function
without manually constructing a secure engine. This is API ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
