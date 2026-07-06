# S4-M481 Root One-Shot Compact Index Choice Helpers

## Gap

S4-M478 added root one-shot `usize` index choice helpers, but the compact `u32`
index workflows available on `Rng` were still missing from the root
system-entropy API. Compact indices are useful for smaller collections and
portable/output-size-sensitive APIs.

## API Added

`src/root.zig` now exposes:

- `chooseIndexU32`
- `chooseIndexU32Checked`
- `fillChooseIndexU32`
- `fillChooseIndexU32Checked`
- `chooseIndexU32Batch`
- `chooseIndexU32BatchChecked`

Empty output buffers and zero-count batches return without drawing entropy.
Length-zero choices return `null` or explicit `EmptyRange` for checked helpers,
and singleton lengths return index `0` without drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `choiceIndexU32` and `indexFillU32` in root
  choice helper output.
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
root choice helpers: choiceIndex=3 (gold), choiceIndexU32=2 (blue), indexFill={ 1, 0, 1, 3 }, indexFillU32={ 2, 2, 1, 2 }, choiceBatch=[blue, blue, blue, gold]
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
examplecheck ok
toolingcheck ok
apicheck ok
roadmapcheck ok
readmecheck ok
```

```text
$ git diff --check
```

## Result

S4-M481 is closed for the current bar: root system-entropy callers can choose
compact `u32` indices without manually constructing a secure engine. This is API
ergonomics work only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
