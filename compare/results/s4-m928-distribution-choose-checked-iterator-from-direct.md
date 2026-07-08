# S4-M928 Distribution Choose Checked Iterator From Direct Constructors

## Gap

Distribution-layer `Choose` direct-source checked iterator constructors still
routed through unchecked direct-source iterator wrappers. The unchecked
constructors are simple iterator construction helpers, so checked direct-source
constructors can build iterators directly after any required prevalidation.

## Local `rand` Baseline

Local Rust `rand` slice-choice iterator workflows construct repeated sampling
iterators over an RNG reference. Alea's distribution-layer `Choose` exposes
Zig-native pointer, value, `usize` index, and compact `u32` direct-source
iterators; the checked direct-source constructors should preserve validation and
stream shape without extra wrapper dispatch.

## Implementation

- `src/distributions.zig` updates `Choose.ptrIterCheckedFrom` to construct the
  pointer iterator directly.
- `src/distributions.zig` updates `Choose.valueIterCheckedFrom` to keep empty-enum
  prevalidation and then construct the value iterator directly.
- `src/distributions.zig` updates `Choose.indexIterCheckedFrom` and
  `Choose.indexIterU32CheckedFrom` to construct index iterators directly,
  preserving compact `u32` length validation.
- `src/distributions.zig` updates pointer `iterCheckedFrom` to construct the
  direct-source sample iterator directly.
- Existing focused tests cover checked direct-source iterator stream shape.

## Validation

Focused distribution Choose test:

```text
$ zig test src/distributions.zig --test-filter "distribution Choose sampler mirrors slice choices"
1/2 distributions.test.distribution Choose sampler mirrors slice choices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
roadmapcheck ok
toolingcheck ok
readmecheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M928 is closed for the current bar: distribution-layer `Choose` checked
direct-source iterator constructors now avoid unchecked direct-source iterator
wrapper aliases while preserving stream shape and checked behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
