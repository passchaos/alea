# S4-M485 Root One-Shot Compact Weighted Index Helpers

## Gap

S4-M480 added root weighted index helpers for `usize`, but compact `u32`
weighted indices still required constructing a secure engine and using
`Rng.weightedIndexU32*`. Compact weighted indices are useful for smaller weighted
choice tables and output-size-sensitive APIs.

## API Added

`src/root.zig` now exposes:

- `weightedIndexU32`
- `weightedIndexU32Checked`
- `fillWeightedIndexU32`
- `fillWeightedIndexU32Checked`
- `weightedIndexU32Batch`
- `weightedIndexU32BatchChecked`

Empty output buffers and zero-count checked batches return without drawing
entropy. Empty/all-zero weights return `null` for nullable helpers, checked
non-empty helpers reject them, and single-positive weights return
deterministically without drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `weightedIndexU32`, `fillU32`, and
  `batchU32` in root weighted helper output.
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
root weighted helpers: weightedIndex=0, weightedIndexU32=1, fill={ 2, 2, 1, 2 }, fillU32={ 2, 0, 1, 2 }, batch={ 1, 2, 2, 2 }, batchU32={ 2, 2, 2, 2 }
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
roadmapcheck ok
toolingcheck ok
readmecheck ok
apicheck ok
```

```text
$ git diff --check
```

## Result

S4-M485 is closed for the current bar: root system-entropy callers can sample
compact `u32` weighted indices without manually constructing a secure engine.
This is API ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
