# S4-M490 Root One-Shot No-Replacement Helpers

## Gap

Root sequence helpers covered choices, shuffles, and weighted draws, but
allocation-returning no-replacement value sampling still required constructing a
secure engine and using `Rng.sampleWithoutReplacement`. Sampling subsets without
replacement is a common collection workflow.

## API Added

`src/root.zig` now exposes:

- `sampleWithoutReplacement`
- `sampleWithoutReplacementChecked`

Zero-count samples and full-length samples return without drawing entropy.
Checked helpers reject impossible counts explicitly.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `root no-replacement helpers` output.
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
root no-replacement helpers: sample={ 5, 6, 2 }
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
apicheck ok
examplecheck ok
readmecheck ok
toolingcheck ok
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M490 is closed for the current bar: root system-entropy callers can allocate
no-replacement value samples without manually constructing a secure engine. This
is API ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
