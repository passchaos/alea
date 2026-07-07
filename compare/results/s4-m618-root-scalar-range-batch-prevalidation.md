# S4-M618 Root Scalar Range Batch Prevalidation

## Gap

Root unchecked scalar range batch helpers allocated output buffers before
validating invalid exclusive or inclusive ranges. Invalid parameters should be
reported before random-output allocation and before root secure-engine
construction for non-zero requests.

This milestone aligns unchecked scalar range batch behavior with root fill
helpers and checked batch prevalidation work.

## API Changed

`src/root.zig` now prevalidates:

- `rangeBatch`
- `rangeAtMostBatch`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Zero-count batches still return empty allocations before validating parameters
  or drawing entropy.
- Invalid exclusive and inclusive ranges return `error.EmptyRange` before
  allocation or entropy for non-zero requests.
- Collapsed deterministic valid paths still allocate and fill deterministic
  values before entropy is requested.
- Random valid paths still allocate the output buffer, construct the root secure
  engine, and delegate to the existing fill paths.

## Adoption and Documentation

- Focused root tests cover invalid-parameter failures before allocation,
  zero-count behavior, deterministic collapsed paths, and failing-entropy random
  paths.
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

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

Broader native test gate:

```text
$ zig build test
roadmapcheck ok
examplecheck ok
readmecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M618 is closed for the current bar: root scalar range batch helpers now
prevalidate invalid ranges before random-output allocation and secure-engine
construction. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
