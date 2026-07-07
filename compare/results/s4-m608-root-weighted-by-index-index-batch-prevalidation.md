# S4-M608 Root By-Index Weighted Index Batch Prevalidation

## Gap

Root `weightedIndexBatchByIndex` and `weightedIndexBatchByIndexChecked`
allocated output buffers before checking invalid weights and deterministic
empty/single length-index weighted states. Those failures should be reported
before random-output allocation and before root secure-engine construction.

This milestone aligns the allocation-returning length/by-index weighted `usize`
index batch helpers with the validated weighted-index root helpers.

## API Changed

`src/root.zig` now prevalidates:

- `weightedIndexBatchByIndex`
- `weightedIndexBatchByIndexChecked`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Zero-count batches still return empty allocations before validating weights or
  drawing entropy.
- Invalid index weights fail before allocation or entropy for non-zero requests.
- Empty/all-zero index weights still return nullable `null` index batches for
  unchecked requests and `error.EmptyInput` for checked requests before entropy.
- Single-positive index weights still allocate and fill repeated indices before
  entropy is requested.
- Multi-positive valid index weights still allocate the output buffer, construct
  the root secure engine, and delegate to the existing weighted fill paths.

## Adoption and Documentation

- Focused root tests cover invalid/all-zero failures before allocation,
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
readmecheck ok
examplecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M608 is closed for the current bar: root length/by-index weighted `usize`
index batch helpers now prevalidate deterministic and invalid paths before
random-output allocation and secure-engine construction. This is reliability and
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
