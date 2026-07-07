# S4-M625 Root Scalar Range Prevalidation

## Gap

Root scalar range scalar/fill helpers relied on debug assertions for invalid
ranges and could proceed toward secure-engine construction before invalid
exclusive or inclusive ranges were reported. Invalid parameters should be
reported before entropy is requested for scalar and non-empty fill requests.

This milestone aligns unchecked scalar range scalar/fill behavior with checked
helpers and batch prevalidation work.

## API Changed

`src/root.zig` now prevalidates:

- `randomRange`
- `randomRangeAtMost`
- `fillRange`
- `fillRangeAtMost`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Empty destinations still return before validating parameters or drawing
  entropy.
- Invalid exclusive and inclusive ranges return `error.EmptyRange` before
  secure-engine construction for scalar and non-empty fill requests.
- Collapsed deterministic valid paths still return/fill deterministic values
  before entropy is requested.
- Random valid paths still construct the root secure engine and delegate to the
  existing random range paths.

## Adoption and Documentation

- Focused root tests cover invalid-range failures before entropy, empty-output
  behavior, deterministic collapsed paths, and failing-entropy random paths.
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
apicheck ok
examplecheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M625 is closed for the current bar: root scalar range scalar/fill helpers now
prevalidate invalid ranges before secure-engine construction. This is reliability
and ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
