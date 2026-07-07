# S4-M592 Root Index Fill/Batch Empty-Range Prevalidation

## Gap

Root `chooseIndex`/`chooseIndexChecked` and fixed-size index array helpers
already handle zero-length ranges deterministically before requesting entropy.
However, root `fillChooseIndex`, `chooseIndexBatch`, `fillChooseIndexU32`, and
`chooseIndexU32Batch` could still construct a secure engine for non-empty
zero-length ranges before reaching lower-level assertions or random paths.

This milestone aligns the fill and allocation-returning index helpers with the
checked root index behavior: impossible non-empty zero-length ranges fail before
entropy is requested, while zero-count batches remain cheap empty allocations.

## API Changed

`src/root.zig` now prevalidates:

- `fillChooseIndex`
- `chooseIndexBatch`
- `fillChooseIndexU32`
- `chooseIndexU32Batch`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Empty destinations still return before validating range length or drawing
  entropy.
- Zero-count batches still return empty allocations before validating range
  length or drawing entropy.
- Non-empty `length == 0` fill/batch requests return `error.EmptyRange` before
  secure-engine construction.
- Single-value ranges still fill/return zeroes before entropy is requested.
- Multi-value ranges still construct the root secure engine and delegate to the
  existing random fill paths.

## Adoption and Documentation

- Focused root tests cover non-empty zero-range failures, zero-count batch
  behavior, existing single-range deterministic paths, and failing-entropy random
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
examplecheck ok
readmecheck ok
toolingcheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M592 is closed for the current bar: root index fill and batch helpers now
reject non-empty zero-length ranges before secure-engine construction. This is
reliability and ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
