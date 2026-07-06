# S4-M495 Root One-Shot Iterator Into Helpers

## Gap

S4-M494 added allocation-returning iterator sampling. Caller-owned iterator
sampling still required constructing a secure engine and using `seq.sampleIteratorInto`.
Caller-owned buffers are important for predictable allocation behavior.

## API Added

`src/root.zig` now exposes:

- `sampleIteratorInto`
- `sampleIteratorIntoChecked`

Empty buffers, short iterators in the unchecked helper, and exact-length checked
samples return without drawing entropy. Checked helpers reject iterators that
cannot fill the caller-provided buffer.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `sampleInto` in root iterator helper output.
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
root iterator helpers: choice=7, weightedChoice=10, sample={ 7, 9, 4, 3 }, sampleInto={ 0, 4, 6, 3 }
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
apicheck ok
readmecheck ok
toolingcheck ok
```

```text
$ git diff --check
```

## Result

S4-M495 is closed for the current bar: root system-entropy callers can fill
caller-owned iterator sample buffers without manually constructing a secure
engine. This is API ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
