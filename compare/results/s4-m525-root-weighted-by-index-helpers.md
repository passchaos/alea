# S4-M525 Root One-Shot Index-Weighted Index Helpers

## Gap

The root API exposed one-shot weighted index helpers for concrete weight slices,
but index-weighted workflows using a length plus a comptime index-weight
function still required constructing a secure engine and calling
`seq.weightedIndexByIndex*` directly.

## API Added

`src/root.zig` now exposes:

- `weightedIndexByIndex`
- `weightedIndexByIndexChecked`
- `weightedIndexU32ByIndex`
- `weightedIndexU32ByIndexChecked`

All-zero/empty weights return `null` for nullable helpers; checked helpers reject
all-zero/empty inputs; single-positive weights return deterministically without
drawing entropy; invalid weights and oversized `u32` requests fail before
entropy is requested.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byIndex=` and `byIndexU32=` in root
  weighted helper output.
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

Runnable example excerpt showing the guarded by-index tokens:

```text
$ zig build run-basic
root weighted helpers: weightedIndex=1, weightedIndexU32=1, byIndex=0, byIndexU32=2, fill={ 1, 2, 0, 1 }, fillU32={ 2, 2, 2, 2 }, array={ 2, 2, 1, 1 }, arrayU32={ 2, 2, 2, 2 }, batch={ 0, 2, 2, 2 }, batchU32={ 2, 0, 0, 1 }
```

```text
$ zig build examplecheck
examplecheck ok
```

```text
$ zig build apicheck
apicheck ok
```

Roadmap guard command was run with an explicit status echo because this cached
build step produced no stdout in this run:

```text
$ zig build roadmapcheck; echo roadmap_status:$?
roadmap_status:0
```

```text
$ git diff --check; echo diffcheck_status:$?
diffcheck_status:0
```

Broader native test gate:

```text
$ zig build test
apicheck ok
toolingcheck ok
readmecheck ok
examplecheck ok
```

## Result

S4-M525 is closed for the current bar: root system-entropy callers can sample a
single `usize` or `u32` weighted index from a length and comptime index-weight
function without manually constructing a secure engine. This is API ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
