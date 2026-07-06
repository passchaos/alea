# S4-M526 Root One-Shot Index-Weighted Fill Helpers

## Gap

S4-M525 added root one-shot index-weighted single-index selection from a length
and comptime index-weight function. Repeated caller-owned fills for the same
index-weighted workflow still required manually constructing a secure engine and
calling `seq.fillWeightedIndexByIndex*` / `seq.fillWeightedIndexU32ByIndex*`.

## API Added

`src/root.zig` now exposes:

- `fillWeightedIndexByIndex`
- `fillWeightedIndexByIndexChecked`
- `fillWeightedIndexU32ByIndex`
- `fillWeightedIndexU32ByIndexChecked`

Zero-length destinations return before validation/entropy. All-zero weights fill
nullable destinations with `null` and checked destinations reject them.
Single-positive weights fill deterministically without drawing entropy. Invalid
weights and oversized `u32` requests fail before entropy is requested.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `fillByIndex=` and `fillU32ByIndex=` in root
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

Runnable example excerpt showing the guarded by-index fill tokens:

```text
$ zig build run-basic
root weighted helpers: weightedIndex=2, weightedIndexU32=2, byIndex=1, byIndexU32=1, fillByIndex={ 2, 2, 2, 1 }, fillU32ByIndex={ 0, 2, 0, 2 }, fill={ 2, 2, 2, 2 }, fillU32={ 2, 2, 1, 2 }, array={ 0, 2, 1, 1 }, arrayU32={ 2, 2, 0, 1 }, batch={ 1, 2, 2, 2 }, batchU32={ 2, 2, 2, 2 }
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
toolingcheck ok
readmecheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M526 is closed for the current bar: root system-entropy callers can fill
caller-owned `usize` or `u32` weighted indexes from a length and comptime
index-weight function without manually constructing a secure engine. This is API
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
