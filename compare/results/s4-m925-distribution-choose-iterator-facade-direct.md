# S4-M925 Distribution Choose Iterator Facade Direct Constructors

## Gap

Distribution-layer `Choose` iterator facade constructors still routed through
direct-source iterator wrappers. The direct-source constructors were simple
wrappers around iterator construction, so facade constructors can build iterators
directly.

## Local `rand` Baseline

Local Rust `rand` slice-choice iterator workflows construct repeated sampling
iterators over an RNG reference. Alea's distribution-layer `Choose` exposes
Zig-native pointer, value, `usize` index, and compact `u32` index iterators; the
facade constructors should preserve stream shape without extra wrapper dispatch.

## Implementation

- `src/distributions.zig` updates `Choose.ptrIter` to construct the pointer
  iterator directly.
- `src/distributions.zig` updates `Choose.valueIter` to construct the value
  iterator directly.
- `src/distributions.zig` updates `Choose.indexIter` and `Choose.indexIterU32` to
  construct index iterators directly, preserving compact `u32` length validation.
- Existing focused tests cover facade/direct iterator stream shape.

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
apicheck ok
roadmapcheck ok
toolingcheck ok
examplecheck ok
readmecheck ok
```

## Result

S4-M925 is closed for the current bar: distribution-layer `Choose` iterator facade
constructors now avoid direct-source iterator wrapper aliases while preserving
stream shape. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
