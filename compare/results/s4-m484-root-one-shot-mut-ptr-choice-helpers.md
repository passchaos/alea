# S4-M484 Root One-Shot Mutable-Pointer Choice Helpers

## Gap

S4-M483 added root one-shot const-pointer choices, but mutable-pointer choices
still required constructing a secure engine and using `Rng.choosePtr*`. Mutable
pointer choices are useful when callers want to select and update elements in a
slice without copying.

## API Added

`src/root.zig` now exposes:

- `choosePtr`
- `choosePtrChecked`
- `fillChoosePtr`
- `fillChoosePtrChecked`
- `choosePtrBatch`
- `choosePtrBatchChecked`
- `choosePtrArray`
- `choosePtrArrayChecked`

Zero-size arrays, empty output buffers, and zero-count batches return without
drawing entropy. Empty inputs return `null` for nullable helpers or explicit
`EmptyRange` for checked helpers, and singleton inputs return deterministic
pointers without drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `root mutable pointer choice helpers` output.
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
root mutable pointer choice helpers: ptr=green, ptrArray=[gold, red, gold, red], ptrBatch=[blue, gold, green, blue]
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
apicheck ok
readmecheck ok
roadmapcheck ok
examplecheck ok
```

```text
$ git diff --check
```

## Result

S4-M484 is closed for the current bar: root system-entropy callers can choose
mutable pointers from slices without manually constructing a secure engine. This
is API ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
