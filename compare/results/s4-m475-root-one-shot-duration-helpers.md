# S4-M475 Root One-Shot Duration Helpers

## Gap

`Rng` supported `std.Io.Duration` less-than/at-most range sampling and batches,
but root system-entropy callers had to construct a secure engine before using
those Zig-native duration workflows. The root one-shot API should cover duration
ranges the same way it now covers scalars, ranges, endpoint floats, strings, and
probability helpers.

## API Added

`src/root.zig` now exposes:

- `durationRangeLessThan`
- `durationRangeLessThanChecked`
- `durationRangeLessThanBatch`
- `durationRangeLessThanBatchChecked`
- `durationRangeAtMost`
- `durationRangeAtMostChecked`
- `durationRangeAtMostBatch`
- `durationRangeAtMostBatchChecked`

Zero-count batches return without drawing entropy. Collapsed at-most ranges
return the fixed duration without drawing entropy. Checked helpers reject invalid
non-empty ranges explicitly.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `root duration helpers` output.
- `tools/examplecheck.zig` guards those example tokens.
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
root duration helpers: lessThan=19968775ns, atMost=13724962ns, lessThanBatch={ .{ .nanoseconds = 10408409 }, .{ .nanoseconds = 14000880 }, .{ .nanoseconds = 12566007 } }, atMostBatch={ .{ .nanoseconds = 10125260 }, .{ .nanoseconds = 15744925 }, .{ .nanoseconds = 16711519 } }
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
readmecheck ok
apicheck ok
examplecheck ok
toolingcheck ok
```

```text
$ git diff --check
```

## Result

S4-M475 is closed for the current bar: root system-entropy callers can sample or
allocate `std.Io.Duration` ranges without manually constructing a secure engine.
This is API ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
