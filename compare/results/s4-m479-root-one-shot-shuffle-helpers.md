# S4-M479 Root One-Shot Shuffle Helpers

## Gap

S4-M478 added root one-shot choice helpers, but in-place sequence mutation still
required constructing a secure engine before calling `seq.shuffle` or
`seq.partialShuffle*`. Root system-entropy callers should be able to run full and
partial shuffles directly for common sequence workflows.

## API Added

`src/root.zig` now exposes:

- `shuffle`
- `partialShuffle`
- `partialShuffleChecked`
- `PartialShuffleSplit`
- `PartialShuffleTailSplit`
- `partialShuffleSplit`
- `partialShuffleSplitChecked`
- `partialShuffleTail`
- `partialShuffleTailChecked`
- `partialShuffleTailSplit`
- `partialShuffleTailSplitChecked`

Empty and singleton no-op paths return without drawing entropy; checked helpers
reject impossible amounts explicitly.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `root shuffle helpers` output.
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
root shuffle helpers: shuffle={ 1, 5, 4, 2, 3, 6 }, partial={ 3, 5, 1 }, tailPartial={ 1, 4, 2 }
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
readmecheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
toolingcheck ok
```

```text
$ git diff --check
```

## Result

S4-M479 is closed for the current bar: root system-entropy callers can run full
and partial in-place shuffles without manually constructing a secure engine. This
is API ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
