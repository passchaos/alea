# S4-M599 Root Weighted Mutable-Pointer Batch Prevalidation

## Gap

Root `chooseWeightedPtrBatch` and `chooseWeightedPtrBatchChecked` allocated their
output buffers before checking length mismatches, invalid weights, and
deterministic empty/single weighted-index states. Those failures should be
reported before random-output allocation and before root secure-engine
construction.

This milestone aligns the allocation-returning weighted mutable-pointer batch
helpers with the validated weighted-index root helpers.

## API Changed

`src/root.zig` now prevalidates:

- `chooseWeightedPtrBatch`
- `chooseWeightedPtrBatchChecked`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Zero-count batches still return empty allocations before validating inputs or
  drawing entropy.
- Length mismatches return `error.InvalidParameter` before allocation or entropy.
- Invalid weights fail before allocation or entropy for non-zero requests.
- Empty/all-zero weights still return nullable `null` pointer batches for
  unchecked requests and `error.EmptyRange` for checked requests before entropy.
- Single-positive weights still allocate and fill repeated mutable pointers
  before entropy is requested.
- Multi-positive valid weights still allocate the output buffer, construct the
  root secure engine, and delegate to the existing weighted fill paths.

## Adoption and Documentation

- Focused root tests cover mismatch/invalid/all-zero failures before allocation,
  zero-count behavior, deterministic empty/single paths including mutable pointer
  write-through coverage elsewhere in the same root test, and failing-entropy
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
toolingcheck ok
roadmapcheck ok
examplecheck ok
readmecheck ok
apicheck ok
```

## Result

S4-M599 is closed for the current bar: root weighted mutable-pointer batch
helpers now prevalidate deterministic and invalid paths before random-output
allocation and secure-engine construction. This is reliability and ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
