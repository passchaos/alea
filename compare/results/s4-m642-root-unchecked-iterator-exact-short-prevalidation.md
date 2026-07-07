# S4-M642 Root Unchecked Iterator Exact-Short Prevalidation

## Gap

Root unchecked iterator sampling helpers intentionally allow short results for
insufficient iterators, matching the saturating iterator-sampling style. However,
when an iterator advertises an exact remaining count, the helper can know the
result shape before allocating for the requested amount or asking for entropy.

Unchecked allocation and array helpers should use exact iterator metadata to
avoid oversized allocation and avoid consuming iterators when the return value is
already determined.

## Local `rand` Baseline

The local Rust checkout remains the baseline comparison source:

- `/home/passchaos/Work/rand/src/seq/iterator.rs` documents that
  `IteratorRandom::sample` returns fewer than the requested amount when the
  iterator contains insufficient elements.
- The same file documents size-hint use for iterator-choice optimizations.

Alea keeps the saturating unchecked behavior, but uses exact metadata to make the
short-result path cheaper and deterministic: allocation is capped to the known
remaining length, and fixed-size array helpers return `null` before entropy or
iterator advancement when exact remaining count is too small.

## API Changed

`src/root.zig` now uses exact iterator metadata in unchecked paths:

- `sampleIterator` caps its initial `ArrayList` capacity to
  `min(amount, exact_remaining)` when exact metadata is available.
- `sampleIteratorArray` returns `null` before consuming an exact-known short
  iterator.
- `sampleIteratorWeightedArray` returns `null` before consuming an exact-known
  short weighted iterator.

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Zero-output calls still return before checking iterator length.
- Exact-known empty or short allocation-returning calls avoid allocating the
  requested oversized amount.
- Exact-known short fixed-size array calls return `null` before secure-engine
  construction and before iterator advancement.
- Unknown-length iterators keep the existing streaming behavior.
- Valid exact and random paths still use the existing reservoir / weighted
  iterator algorithms.

## Adoption and Documentation

- Focused root tests cover exact-short/empty behavior before allocation, entropy,
  and iterator consumption, plus existing checked exact-short, empty,
  deterministic, and failing-entropy iterator paths.
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
roadmapcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M642 is closed for the current bar: root unchecked iterator allocation/array
helpers now avoid oversized allocation and return deterministic exact-short
results before secure-engine construction and iterator consumption where exact
iterator metadata proves the outcome. This is reliability and ergonomics work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
