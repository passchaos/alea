# S4-M483 Root One-Shot Const-Pointer Choice Helpers

## Gap

Root one-shot choice helpers could return copied values, indexes, batches, and
fixed-size arrays, but const-pointer choices still required constructing a secure
engine and using `Rng.chooseConstPtr*`. Const-pointer choices are useful when
callers want references to borrowed or large values without copying them.

## API Added

`src/root.zig` now exposes:

- `chooseConstPtr`
- `chooseConstPtrChecked`
- `fillChooseConstPtr`
- `fillChooseConstPtrChecked`
- `chooseConstPtrBatch`
- `chooseConstPtrBatchChecked`
- `chooseConstPtrArray`
- `chooseConstPtrArrayChecked`

Zero-size arrays, empty output buffers, and zero-count batches return without
drawing entropy. Empty inputs return `null` for nullable helpers or explicit
`EmptyRange` for checked helpers, and singleton inputs return deterministic
pointers without drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `root pointer choice helpers` output.
- `tools/examplecheck.zig` guards those example tokens.
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
root pointer choice helpers: ptr=gold, ptrArray=[gold, blue, gold, gold], ptrBatch=[red, red, green, red]
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
examplecheck ok
readmecheck ok
apicheck ok
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M483 is closed for the current bar: root system-entropy callers can choose
const pointers from slices without manually constructing a secure engine. This is
API ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
