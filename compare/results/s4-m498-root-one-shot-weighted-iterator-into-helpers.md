# S4-M498 Root One-Shot Weighted Iterator Into Helpers

## Gap

S4-M497 added allocation-returning weighted iterator sampling. Caller-owned
weighted iterator sampling still required constructing a secure engine and using
`seq.sampleIteratorWeightedInto`. Caller-owned buffers are important for
predictable allocation behavior in streaming weighted workflows.

## API Added

`src/root.zig` now exposes:

- `sampleIteratorWeightedInto`
- `sampleIteratorWeightedIntoChecked`

Empty buffers return without drawing entropy. Helpers validate scratch-key buffer
length before drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `weightedInto` in root iterator helper
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
root iterator helpers: choice=0, weightedChoice=30, sample={ 6, 9, 2, 3 }, sampleInto={ 0, 9, 8, 3 }, sampleArray={ 6, 1, 2, 3 }, weightedSample={ 20, 30 }, weightedInto={ 20, 30 }
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
roadmapcheck ok
examplecheck ok
apicheck ok
toolingcheck ok
```

```text
$ git diff --check
```

## Result

S4-M498 is closed for the current bar: root system-entropy callers can fill
caller-owned weighted iterator sample buffers without manually constructing a
secure engine. This is API ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
