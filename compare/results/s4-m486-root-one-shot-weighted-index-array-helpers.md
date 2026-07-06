# S4-M486 Root One-Shot Weighted Index Array Helpers

## Gap

Root weighted index helpers covered scalar, fill, and allocation-returning batch
workflows for `usize` and compact `u32` indices, but stack-friendly fixed-size
weighted index arrays still required constructing a secure engine and using
`Rng.weightedIndexArray*` / `Rng.weightedIndexU32Array*`.

## API Added

`src/root.zig` now exposes:

- `weightedIndexArray`
- `weightedIndexArrayChecked`
- `weightedIndexU32Array`
- `weightedIndexU32ArrayChecked`

Zero-size arrays return without drawing entropy. Empty/all-zero weights return
`null` for nullable helpers, checked helpers reject them, and single-positive
weights return deterministic arrays without drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `array` and `arrayU32` in root weighted
  helper output.
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
root weighted helpers: weightedIndex=2, weightedIndexU32=2, fill={ 0, 2, 2, 1 }, fillU32={ 1, 0, 0, 1 }, array={ 0, 2, 2, 2 }, arrayU32={ 2, 2, 2, 1 }, batch={ 1, 2, 2, 1 }, batchU32={ 2, 2, 2, 2 }
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
readmecheck ok
toolingcheck ok
apicheck ok
```

```text
$ git diff --check
```

## Result

S4-M486 is closed for the current bar: root system-entropy callers can produce
fixed-size weighted `usize` and `u32` index arrays without manually constructing
a secure engine. This is API ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
