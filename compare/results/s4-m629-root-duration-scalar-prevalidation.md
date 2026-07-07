# S4-M629 Root Duration Scalar Range Prevalidation

## Gap

Root duration range scalar helpers relied on debug assertions for invalid ranges
and could proceed toward secure-engine construction before invalid ranges were
reported. Invalid parameters should be reported before entropy is requested.

This milestone aligns duration scalar behavior with checked helpers and duration
batch prevalidation work.

## API Changed

`src/root.zig` now prevalidates:

- `durationRangeLessThan`
- `durationRangeAtMost`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Invalid duration ranges return `error.EmptyRange` before secure-engine
  construction.
- Deterministic inclusive paths, where `min == max`, still return the fixed
  duration before entropy is requested.
- Random valid paths still construct the root secure engine and sample through
  the existing duration random paths.

## Adoption and Documentation

- Focused root tests cover invalid-range failures before entropy, deterministic
  collapsed inclusive paths, and failing-entropy random paths.
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
roadmapcheck ok
examplecheck ok
apicheck ok
toolingcheck ok
```

## Result

S4-M629 is closed for the current bar: root duration range scalar helpers now
prevalidate invalid ranges before secure-engine construction. This is reliability
and ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
