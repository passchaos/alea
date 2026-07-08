# S4-M930 WeightedChoice Checked Iterator From Direct Constructors

## Gap

Reusable `WeightedChoice` direct-source checked iterator constructors still routed
through unchecked direct-source iterator wrappers. The unchecked constructors are
simple iterator construction helpers, so checked direct-source constructors can
build iterators directly after any required prevalidation.

## Local `rand` Baseline

Local Rust `rand` weighted selection exposes `WeightedIndex` and slice
`choose_weighted` / `choose_weighted_iter` workflows: construct the weighted
sampler, then repeatedly sample indexes or items from an RNG reference. Alea's
reusable `WeightedChoice` exposes Zig-native pointer, value, `usize` index, and
compact `u32` direct-source iterators backed by the alias table; the checked
direct-source constructors should preserve validation and stream shape without
extra wrapper dispatch.

## Implementation

- `src/seq.zig` updates `WeightedChoice.valueIterCheckedFrom` to keep empty-enum
  prevalidation and then construct the value iterator directly.
- `src/seq.zig` updates `WeightedChoice.indexIterCheckedFrom` and
  `WeightedChoice.indexIterU32CheckedFrom` to construct index iterators directly,
  preserving compact `u32` length validation.
- `src/seq.zig` updates pointer `iterCheckedFrom` and `ptrIterCheckedFrom` aliases
  to construct direct-source sample iterators directly.
- Focused tests cover checked direct-source iterator stream shape for weighted
  item and index workflows.

## Validation

Focused reusable WeightedChoice tests:

```text
$ zig test src/seq.zig --test-filter "weighted choice sampler maps alias indexes to items"
1/2 seq.test.weighted choice sampler maps alias indexes to items...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "WeightedChoice index iterators produce repeated indices"
1/2 seq.test.WeightedChoice index iterators produce repeated indices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M930 is closed for the current bar: reusable `WeightedChoice` checked
direct-source iterator constructors now avoid unchecked direct-source iterator
wrapper aliases while preserving stream shape and checked behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
