# S4-M502 Root One-Shot Weighted No-Replacement Array Helpers

## Gap

S4-M501 added allocation-returning weighted no-replacement value sampling. The
fixed-size array form still required constructing a secure engine and using
`seq.sampleWeightedArray*`.

## API Added

`src/root.zig` now exposes:

- `sampleWeightedArray`
- `sampleWeightedArrayChecked`

Zero-size arrays return without drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `weightedArray` in root no-replacement helper
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
root no-replacement helpers: sample={ 4, 5, 6 }, indices={ 2, 3, 0 }, indicesInto={ 0, 1, 2 }, indicesU32={ 4, 3, 0 }, weightedIndices={ 1, 2 }, weightedValues=[green, blue], weightedArray=[red, blue]
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
toolingcheck ok
apicheck ok
roadmapcheck ok
readmecheck ok
```

```text
$ git diff --check
```

## Result

S4-M502 is closed for the current bar: root system-entropy callers can produce
fixed-size weighted no-replacement value arrays without manually constructing a
secure engine. This is API ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
