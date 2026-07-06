# S4-M478 Root One-Shot Choice Helpers

## Gap

The root system-entropy API covered sampler draws and many scalar/batch helpers,
but common sequence-selection workflows still required constructing a secure
engine before using `Rng.chooseIndex`, `Rng.choose`, or their fill/batch forms.
Alea should let root callers choose indices and values directly while preserving
explicit `std.Io` entropy.

## API Added

`src/root.zig` now exposes:

- `chooseIndex`
- `chooseIndexChecked`
- `fillChooseIndex`
- `fillChooseIndexChecked`
- `chooseIndexBatch`
- `chooseIndexBatchChecked`
- `choose`
- `chooseChecked`
- `fillChoose`
- `fillChooseChecked`
- `chooseBatch`
- `chooseBatchChecked`

Empty output buffers and zero-count batches return without drawing entropy.
Empty choices return `null` or explicit `EmptyRange` for checked helpers, and
single-choice inputs return deterministically without drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `root choice helpers` output.
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
root choice helpers: choiceIndex=3 (gold), indexFill={ 1, 0, 2, 1 }, choiceBatch=[blue, blue, gold, blue]
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
apicheck ok
toolingcheck ok
readmecheck ok
examplecheck ok
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M478 is closed for the current bar: root system-entropy callers can choose
indices and values from lengths/slices without manually constructing a secure
engine. This is API ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
