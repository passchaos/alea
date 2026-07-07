# S4-M627 Root Probability Scalar/Fill Prevalidation

## Gap

Root unchecked boolean probability and ratio scalar/fill helpers relied on debug
assertions for invalid parameters and could proceed toward secure-engine
construction before invalid probabilities or ratios were reported. Invalid
parameters should be reported before entropy is requested for scalar and
non-empty fill requests.

This milestone aligns unchecked probability scalar/fill behavior with checked
helpers and batch prevalidation work.

## API Changed

`src/root.zig` now prevalidates:

- `randomBool`
- `randomRatio`
- `fillRandomBool`
- `fillRandomRatio`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Empty destinations still return before validating parameters or drawing
  entropy.
- Invalid probabilities and ratios return `error.InvalidProbability` before
  secure-engine construction for scalar and non-empty fill requests.
- Endpoint deterministic paths still return/fill deterministic booleans before
  entropy is requested.
- Random valid paths still construct the root secure engine and delegate to the
  existing random probability paths.

## Adoption and Documentation

- Focused root tests cover invalid-parameter failures before entropy,
  empty-output behavior, deterministic endpoint paths, and failing-entropy random
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
readmecheck ok
toolingcheck ok
examplecheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M627 is closed for the current bar: root boolean probability and ratio
scalar/fill helpers now prevalidate invalid parameters before secure-engine
construction. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
