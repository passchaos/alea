# S4-M472 Root One-Shot Allocation Batch Helpers

## Gap

S4-M471 added root one-shot caller-owned fill helpers for range and probability
buffers. The root system-entropy API still lacked allocation-returning batch
helpers, so users who wanted owned random value/range/probability batches had to
manually allocate and call fill helpers or construct a secure engine and use the
`Rng` facade.

## API Added

`src/root.zig` now exposes:

- `valueBatch`
- `valueBatchChecked`
- `rangeBatch`
- `rangeBatchChecked`
- `rangeAtMostBatch`
- `rangeAtMostBatchChecked`
- `randomBoolBatch`
- `randomBoolBatchChecked`
- `randomRatioBatch`
- `randomRatioBatchChecked`

The helpers allocate the requested slice, fill it through the root one-shot
system-entropy path, and free on failure. Zero-count checked helpers return empty
owned slices before parameter validation, matching the existing `Rng` batch
helper convention.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `valueBatch`, `rangeBatch`, `boolBatch`, and
  `ratioBatch` in the root random helper output.
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
root random helpers: random=28694, range=1, bool=false, fill={ 194, 107, 241, 89 }, rangeFill={ 6, 3, 5, 1 }, inclusiveFill={ 4, 1, 2, 4 }, boolFill={ false, false, true, true, false, false, false, false }, ratioFill={ false, true, false, false, false, true, true, true }, valueBatch={ 10774, 43782, 29267, 8018 }, rangeBatch={ 1, 5, 5, 5 }, boolBatch={ true, false, false, false }, ratioBatch={ false, true, true, true }, iterNext=215, iterUnbounded=true
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
apicheck ok
roadmapcheck ok
examplecheck ok
```

```text
$ git diff --check
```

## Result

S4-M472 is closed for the current bar: root system-entropy callers can allocate
random value, range, and probability batches without manually constructing a
secure engine. This is API ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
