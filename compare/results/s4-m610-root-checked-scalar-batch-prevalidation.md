# S4-M610 Root Checked Scalar Batch Parameter Prevalidation

## Gap

Root checked scalar batch helpers allocated output buffers before validating some
invalid parameters. Invalid exclusive ranges, invalid boolean probabilities, and
invalid ratios should be reported before random-output allocation and before root
secure-engine construction for non-zero requests.

This milestone aligns those checked batch helpers with the root fill helpers and
with earlier batch prevalidation work.

## API Changed

`src/root.zig` now prevalidates:

- `rangeBatchChecked`
- `randomBoolBatchChecked`
- `randomRatioBatchChecked`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Zero-count batches still return empty allocations before validating parameters
  or drawing entropy.
- Invalid exclusive ranges return `error.EmptyRange` before allocation or
  entropy for non-zero requests.
- Invalid boolean probabilities and ratios return `error.InvalidProbability`
  before allocation or entropy for non-zero requests.
- Collapsed deterministic valid paths, such as a one-value exclusive integer
  range or probability/ratio endpoints, still allocate and fill deterministic
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
toolingcheck ok
readmecheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M610 is closed for the current bar: root checked scalar batch helpers now
prevalidate invalid parameters before random-output allocation and secure-engine
construction. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
