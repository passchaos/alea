# S4-M488 Root One-Shot Weighted Const-Pointer Helpers

## Gap

S4-M487 added weighted value helpers, but weighted const-pointer choices still
required constructing a secure engine or converting weighted indices manually.
Weighted const-pointer choices are useful when callers want borrowed references
to large or externally-owned values under weighted sampling.

## API Added

`src/root.zig` now exposes:

- `chooseWeightedConstPtr`
- `chooseWeightedConstPtrChecked`
- `fillChooseWeightedConstPtr`
- `fillChooseWeightedConstPtrChecked`
- `chooseWeightedConstPtrBatch`
- `chooseWeightedConstPtrBatchChecked`
- `chooseWeightedConstPtrArray`
- `chooseWeightedConstPtrArrayChecked`

Empty output buffers, zero-count batches, zero-size arrays, and single-positive
weights return without drawing entropy. Helpers validate item/weight length
mismatches before drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `root weighted pointer helpers` output.
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
root weighted pointer helpers: ptr=blue, ptrArray=[red, blue, blue, blue], ptrBatch=[blue, blue, green, blue]
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

S4-M488 is closed for the current bar: root system-entropy callers can sample
weighted const pointers without manually constructing a secure engine. This is
API ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
