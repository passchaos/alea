# S4-M596 Root Weighted-Index Invalid-Weight Prevalidation

## Gap

Some root weighted-index helpers used the lower-level unchecked weighted-index
paths after converting validation failures into the random path. Invalid weights
could therefore construct a secure engine before failing, and allocation-returning
batch helpers could allocate output buffers before deterministic validation had
proved the request needed random sampling.

This milestone tightens the root behavior so invalid weights and deterministic
empty/single cases are validated before secure-engine construction. Batch helpers
also validate deterministic cases before allocating random-output buffers.

## API Changed

`src/root.zig` now prevalidates:

- `weightedIndex`
- `fillWeightedIndex`
- `weightedIndexBatch`
- `weightedIndexBatchChecked`
- `fillWeightedIndexU32`
- `weightedIndexU32Batch`
- `weightedIndexU32BatchChecked`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Empty outputs and zero-count batches still return before validating weights or
  drawing entropy.
- Empty/all-zero weights still produce `null` outputs or checked empty-range
  errors before entropy is requested.
- Single-positive weights still fill/return the single index before entropy is
  requested.
- Invalid weights fail before secure-engine construction and, for non-zero
  batch requests, before allocating random-output buffers.
- Multi-positive valid weights still construct the root secure engine and
  delegate to the existing weighted-index fill paths.

## Adoption and Documentation

- Focused root tests cover invalid-weight failures before entropy/allocation,
  zero-count behavior, deterministic empty/single paths, and failing-entropy
  random paths.
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
apicheck ok
roadmapcheck ok
examplecheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M596 is closed for the current bar: root weighted-index helpers now validate
invalid-weight paths before secure-engine construction and before random-output
batch allocation. This is reliability and ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
