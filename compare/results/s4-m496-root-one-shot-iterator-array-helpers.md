# S4-M496 Root One-Shot Iterator Array Helpers

## Gap

S4-M494/S4-M495 added allocation-returning and caller-owned iterator sampling.
Fixed-size iterator sample arrays still required constructing a secure engine and
using `seq.sampleIteratorArray*`. These arrays are useful when callers want a
comptime-known reservoir sample without allocator traffic.

## API Added

`src/root.zig` now exposes:

- `sampleIteratorArray`
- `sampleIteratorArrayChecked`

Zero-size arrays, short iterators for the nullable helper, and exact-length
checked samples return without drawing entropy. Checked helpers reject iterators
that cannot fill the fixed-size array.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `sampleArray` in root iterator helper output.
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
root iterator helpers: choice=8, weightedChoice=10, sample={ 0, 1, 5, 9 }, sampleInto={ 8, 1, 7, 4 }, sampleArray={ 9, 8, 2, 6 }
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

S4-M496 is closed for the current bar: root system-entropy callers can produce
fixed-size iterator sample arrays without manually constructing a secure engine.
This is API ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
