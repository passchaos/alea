# S4-M619 Root Probability Batch Prevalidation

## Gap

Root unchecked boolean probability and ratio batch helpers allocated output
buffers before validating invalid probabilities or ratios. Invalid parameters
should be reported before random-output allocation and before root secure-engine
construction for non-zero requests.

This milestone aligns unchecked probability batch behavior with root fill helpers
and checked batch prevalidation work.

## API Changed

`src/root.zig` now prevalidates:

- `randomBoolBatch`
- `randomRatioBatch`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Zero-count batches still return empty allocations before validating parameters
  or drawing entropy.
- Invalid probabilities and ratios return `error.InvalidProbability` before
  allocation or entropy for non-zero requests.
- Endpoint deterministic paths, such as `p == 0`, `p == 1`, numerator zero, or
  numerator equal to denominator, still allocate and fill deterministic booleans
  before entropy is requested.
- Random valid paths still allocate the output buffer, construct the root secure
  engine, and delegate to the existing fill paths.

## Adoption and Documentation

- Focused root tests cover invalid-parameter failures before allocation,
  zero-count behavior, deterministic endpoint paths, and failing-entropy random
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
apicheck ok
toolingcheck ok
examplecheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M619 is closed for the current bar: root boolean probability and ratio batch
helpers now prevalidate invalid parameters before random-output allocation and
secure-engine construction. This is reliability and ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
