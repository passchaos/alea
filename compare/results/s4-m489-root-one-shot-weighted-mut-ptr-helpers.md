# S4-M489 Root One-Shot Weighted Mutable-Pointer Helpers

## Gap

S4-M488 added weighted const-pointer helpers, but weighted mutable-pointer choices
still required constructing a secure engine or converting weighted indices
manually. Weighted mutable-pointer choices are useful when callers want to select
and update writable slice elements under weighted sampling.

## API Added

`src/root.zig` now exposes:

- `chooseWeightedPtr`
- `chooseWeightedPtrChecked`
- `fillChooseWeightedPtr`
- `fillChooseWeightedPtrChecked`
- `chooseWeightedPtrBatch`
- `chooseWeightedPtrBatchChecked`
- `chooseWeightedPtrArray`
- `chooseWeightedPtrArrayChecked`

Empty output buffers, zero-count batches, zero-size arrays, and single-positive
weights return without drawing entropy. Helpers validate item/weight length
mismatches before drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `root weighted mutable pointer helpers`
  output.
- `tools/examplecheck.zig` guards that example token.
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

Runnable example and guard checks:

```text
$ zig build run-basic
root weighted mutable pointer helpers: ptr=blue, ptrArray=[green, blue, green, red], ptrBatch=[red, blue, blue, green]
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

Broader native test gate:

```text
$ zig build test
toolingcheck ok
roadmapcheck ok
apicheck ok
readmecheck ok
examplecheck ok
```

```text
$ git diff --check
```

## Result

S4-M489 is closed for the current bar: root system-entropy callers can sample
weighted mutable pointers without manually constructing a secure engine. This is
API ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
