# S4-M501 Root One-Shot Weighted No-Replacement Value Helpers

## Gap

S4-M500 added weighted no-replacement index sampling, but root callers still had
to map those indexes to values manually or construct a secure engine and call
`seq.sampleWeighted*`. Direct weighted no-replacement value sampling is the
higher-level collection workflow most callers want.

## API Added

`src/root.zig` now exposes:

- `sampleWeighted`
- `sampleWeightedChecked`

Zero-count samples return without drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `weightedValues` in root no-replacement
  helper output.
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
root no-replacement helpers: sample={ 5, 6, 2 }, indices={ 5, 0, 1 }, indicesInto={ 2, 5, 1 }, indicesU32={ 3, 4, 5 }, weightedIndices={ 1, 2 }, weightedValues=[blue, green]
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
apicheck ok
readmecheck ok
examplecheck ok
toolingcheck ok
```

```text
$ git diff --check
```

## Result

S4-M501 is closed for the current bar: root system-entropy callers can allocate
weighted no-replacement value samples without manually constructing a secure
engine. This is API ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
