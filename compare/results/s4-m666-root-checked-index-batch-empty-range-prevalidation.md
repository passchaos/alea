# S4-M666 Root Checked Index Batch Empty-Range Prevalidation

## Gap

S4-M592 tightened unchecked root index fill and batch helpers so non-empty
zero-length ranges fail before entropy. The checked allocation-returning index
batch helpers still allocated their output buffers before delegating to checked
fill helpers for non-zero `length == 0` requests.

Root checked index batch helpers should reject non-zero zero-length ranges before
allocation and before secure-engine construction.

## Local `rand` Baseline

The local Rust `rand` checkout exposes index and slice choice workflows through
range sampling and slice distributions. Empty ranges/slices are rejected before
sampling. Alea's root helpers are Zig-native system-entropy conveniences; S4-M666
aligns checked owned index batches with the same pre-sampling validation rule.

## API Changed

`src/root.zig` now prevalidates empty ranges in:

- `chooseIndexBatchChecked`
- `chooseIndexU32BatchChecked`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Zero-count requests still return empty allocations before validating range
  length or drawing entropy.
- Non-zero `length == 0` checked index batches return `error.EmptyRange` before
  allocation and secure-engine construction.
- Single-value ranges still return zero-filled batches before entropy.
- Multi-value ranges keep existing allocation and secure random paths.

## Adoption and Documentation

- Focused root tests cover checked usize/u32 index batch empty-range failures
  with failing allocators, proving the invalid paths do not allocate or request
  entropy, plus existing zero-count and singleton deterministic behavior.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused root test:

```text
$ zig test src/root.zig --test-filter "root random helpers validate deterministic cases before entropy"
1/2 root.test_0...OK
2/2 root.test.root random helpers validate deterministic cases before entropy...OK
All 2 tests passed.
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

No output.

Broader native test gate:

```text
$ zig build test
toolingcheck ok
readmecheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M666 is closed for the current bar: root checked index batch helpers now
reject non-zero zero-length ranges before allocation, secure-engine construction,
or assertions. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
