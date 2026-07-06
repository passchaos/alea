# S4-M487 Root One-Shot Weighted Value Helpers

## Gap

Root weighted helpers covered weighted indices, but root callers still had to
convert indices to values manually or construct a secure engine and use
`Rng.chooseWeighted*` for direct weighted value selection. Weighted value choices
are a common higher-level workflow over weighted indices.

## API Added

`src/root.zig` now exposes:

- `chooseWeighted`
- `chooseWeightedChecked`
- `fillChooseWeighted`
- `fillChooseWeightedChecked`
- `chooseWeightedBatch`
- `chooseWeightedBatchChecked`
- `chooseWeightedValueArray`
- `chooseWeightedValueArrayChecked`

Empty output buffers, zero-count batches, zero-size arrays, and single-positive
weights return without drawing entropy. Helpers validate item/weight length
mismatches before drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `root weighted value helpers` output.
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
root weighted value helpers: value=blue, fill=[blue, blue, blue, green], array=[blue, blue, blue, green], batch=[green, green, blue, red]
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
toolingcheck ok
roadmapcheck ok
examplecheck ok
readmecheck ok
```

```text
$ git diff --check
```

## Result

S4-M487 is closed for the current bar: root system-entropy callers can sample
weighted values without manually constructing a secure engine. This is API
ergonomics work only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
