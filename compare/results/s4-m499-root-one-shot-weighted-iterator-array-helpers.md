# S4-M499 Root One-Shot Weighted Iterator Array Helpers

## Gap

S4-M497/S4-M498 added allocation-returning and caller-owned weighted iterator
sampling. Fixed-size weighted iterator sample arrays still required constructing
a secure engine and using `seq.sampleIteratorWeightedArray*`.

## API Added

`src/root.zig` now exposes:

- `sampleIteratorWeightedArray`
- `sampleIteratorWeightedArrayChecked`

Zero-size arrays return without drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `weightedArray` in root iterator helper
  output.
- `tools/examplecheck.zig` guards that example token.
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
root iterator helpers: choice=8, weightedChoice=30, sample={ 0, 6, 4, 3 }, sampleInto={ 8, 4, 6, 9 }, sampleArray={ 0, 5, 6, 7 }, weightedSample={ 10, 30 }, weightedInto={ 20, 30 }, weightedArray={ 20, 30 }
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
toolingcheck ok
examplecheck ok
apicheck ok
readmecheck ok
```

```text
$ git diff --check
```

## Result

S4-M499 is closed for the current bar: root system-entropy callers can produce
fixed-size weighted iterator sample arrays without manually constructing a secure
engine. This is API ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
