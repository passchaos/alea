# S4-M480 Root One-Shot Weighted Index Helpers

## Gap

The root system-entropy API covered unweighted choice and shuffle workflows, but
weighted index selection still required constructing a secure engine before using
`Rng.weightedIndex` or its fill/batch forms. Weighted index sampling is a common
`rand`/`rand_distr` workflow and should be available from the root one-shot API.

## API Added

`src/root.zig` now exposes:

- `weightedIndex`
- `weightedIndexChecked`
- `fillWeightedIndex`
- `fillWeightedIndexChecked`
- `weightedIndexBatch`
- `weightedIndexBatchChecked`

Empty output buffers and zero-count checked batches return without drawing
entropy. Empty/all-zero weights return `null` for nullable helpers, checked
non-empty helpers reject them, and single-positive weights return
deterministically without drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `root weighted helpers` output.
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
root weighted helpers: weightedIndex=0, fill={ 2, 2, 1, 2 }, batch={ 2, 2, 2, 1 }
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
readmecheck ok
roadmapcheck ok
examplecheck ok
apicheck ok
```

```text
$ git diff --check
```

## Result

S4-M480 is closed for the current bar: root system-entropy callers can sample
weighted indices without manually constructing a secure engine. This is API
ergonomics work only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
