# S4-M497 Root One-Shot Weighted Iterator Sampling Helpers

## Gap

Root iterator helpers covered unweighted choice/sampling plus weighted choice,
but allocation-returning weighted iterator sampling still required constructing a
secure engine and using `seq.sampleIteratorWeighted*`. Weighted iterator
reservoir sampling is useful when callers produce weighted entries lazily and
need more than one sampled item.

## API Added

`src/root.zig` now exposes:

- `sampleIteratorWeighted`
- `sampleIteratorWeightedChecked`

Zero-count samples return without drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `weightedSample` in root iterator helper
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
root iterator helpers: choice=7, weightedChoice=20, sample={ 8, 9, 2, 7 }, sampleInto={ 0, 6, 7, 5 }, sampleArray={ 7, 4, 9, 5 }, weightedSample={ 10, 20 }
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
apicheck ok
roadmapcheck ok
toolingcheck ok
examplecheck ok
readmecheck ok
```

```text
$ git diff --check
```

## Result

S4-M497 is closed for the current bar: root system-entropy callers can allocate
weighted iterator samples without manually constructing a secure engine. This is
API ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
