# S4-M643 Root Weighted Index Allocation Prevalidation

## Gap

Root parallel-weighted index allocation helpers delegated directly to lower-level
sampling for non-zero requests. That meant empty inputs, all-zero weights,
single-positive weights, invalid weights, checked oversized requests, and u32
length limits were not handled at the root layer before secure-engine
construction.

These cases have deterministic results or deterministic errors and should not
request system entropy.

## Local `rand` Baseline

The local Rust checkout remains the baseline comparison source:

- `/home/passchaos/Work/rand/src/seq/index.rs` implements weighted index
  sampling by scanning weights, returning `InvalidWeight` for negative/NaN
  weights and producing fewer than the requested amount when insufficient
  positive weights are available.
- Alea's root API keeps Zig-native fallible semantics: unchecked weighted index
  allocation helpers may return fewer results, while checked variants return
  `error.InvalidParameter` for impossible exact-count requests.

S4-M643 moves the deterministic scan into root helpers so callers avoid secure
entropy when the result/error is already known.

## API Changed

`src/root.zig` now prevalidates:

- `sampleWeightedIndices`
- `sampleWeightedIndicesChecked`
- `sampleWeightedIndicesU32`
- `sampleWeightedIndicesU32Checked`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Zero-amount requests still return empty allocations before drawing entropy.
- Empty non-zero unchecked requests return `error.EmptyInput`; checked variants
  return `error.InvalidParameter` through the oversized-count check.
- All-zero weights return empty allocations in unchecked helpers and
  `error.InvalidParameter` in checked helpers.
- Single-positive weights return the deterministic single index before entropy.
- Invalid weights and u32 length limits are reported before entropy.
- Random valid multi-positive paths still construct the root secure engine and
  delegate to the existing weighted sampling paths.

## Adoption and Documentation

- Focused root tests cover empty, all-zero, single-positive, checked oversized,
  u32, and failing-entropy random paths.
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

No output.

Broader native test gate:

```text
$ zig build test
readmecheck ok
toolingcheck ok
examplecheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M643 is closed for the current bar: root parallel-weighted index allocation
helpers now resolve deterministic result/error cases before secure-engine
construction. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
