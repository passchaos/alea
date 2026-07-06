# S4-M482 Root One-Shot Fixed-Size Choice Array Helpers

## Gap

Root choice helpers covered scalar, fill, and allocation-returning batches, but
stack-friendly fixed-size choice arrays still required constructing a secure
engine and calling `Rng.choose*Array`. These fixed-size arrays are useful in Zig
when callers want comptime-known output sizes without allocator traffic.

## API Added

`src/root.zig` now exposes:

- `chooseIndexArray`
- `chooseIndexArrayChecked`
- `chooseIndexArrayU32`
- `chooseIndexArrayU32Checked`
- `chooseValueArray`
- `chooseValueArrayChecked`

Zero-size arrays return without drawing entropy. Empty inputs return `null` for
nullable helpers or explicit `EmptyRange` for checked helpers, and singleton
inputs return deterministic arrays without drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `indexArray`, `indexArrayU32`, and
  `valueArray` in root choice helper output.
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
root choice helpers: choiceIndex=2 (blue), choiceIndexU32=1 (green), indexFill={ 1, 0, 0, 0 }, indexFillU32={ 3, 1, 1, 2 }, indexArray={ 2, 3, 3, 3 }, indexArrayU32={ 3, 1, 3, 2 }, valueArray=[blue, blue, red, blue], choiceBatch=[red, red, red, gold]
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
roadmapcheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
apicheck ok
```

```text
$ git diff --check
```

## Result

S4-M482 is closed for the current bar: root system-entropy callers can produce
fixed-size index and value choice arrays without manually constructing a secure
engine. This is API ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
