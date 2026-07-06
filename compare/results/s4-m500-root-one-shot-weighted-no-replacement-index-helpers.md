# S4-M500 Root One-Shot Weighted No-Replacement Index Helpers

## Gap

Root weighted helpers covered repeated weighted index/value sampling and weighted
iterator sampling, but weighted no-replacement index sampling still required
constructing a secure engine and using `seq.sampleWeightedIndices*`. This is the
weighted subset counterpart to S4-M491 no-replacement index sampling.

## API Added

`src/root.zig` now exposes:

- `sampleWeightedIndices`
- `sampleWeightedIndicesChecked`
- `sampleWeightedIndicesU32`
- `sampleWeightedIndicesU32Checked`

Zero-count samples return without drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `weightedIndices` in root no-replacement
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
root no-replacement helpers: sample={ 5, 2, 4 }, indices={ 3, 0, 1 }, indicesInto={ 3, 1, 4 }, indicesU32={ 0, 4, 2 }, weightedIndices={ 1, 2 }
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
readmecheck ok
roadmapcheck ok
examplecheck ok
apicheck ok
toolingcheck ok
```

```text
$ git diff --check
```

## Result

S4-M500 is closed for the current bar: root system-entropy callers can allocate
weighted no-replacement index samples without manually constructing a secure
engine. This is API ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
