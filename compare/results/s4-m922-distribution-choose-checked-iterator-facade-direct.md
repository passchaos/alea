# S4-M922 Distribution Choose Checked Iterator Facade Direct Constructors

## Gap

Distribution-layer `Choose` checked iterator facade constructors still routed
through direct-source checked iterator wrappers. The checked direct-source
constructors were simple wrappers around iterator construction, so facade checked
constructors can build the iterator directly after any required prevalidation.

## Local `rand` Baseline

Local Rust `rand` slice-choice iterator workflows construct repeated sampling
iterators over an RNG reference. Alea's distribution-layer `Choose` exposes
Zig-native pointer, value, `usize` index, and compact `u32` index iterators; the
checked facade constructors should preserve validation and stream shape without
extra wrapper dispatch.

## Implementation

- `src/distributions.zig` updates `Choose.ptrIterChecked` to construct the pointer
  iterator directly.
- `src/distributions.zig` updates `Choose.valueIterChecked` to keep empty-enum
  prevalidation and then construct the value iterator directly.
- `src/distributions.zig` updates `Choose.indexIterChecked` and
  `Choose.indexIterU32Checked` to construct index iterators directly, preserving
  compact `u32` length validation.
- `src/distributions.zig` updates the pointer `iterChecked` alias to construct the
  facade sample iterator directly.
- Existing focused tests cover facade/direct checked iterator stream shape.

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
readmecheck ok
examplecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M922 is closed for the current bar: distribution-layer `Choose` checked iterator
facade constructors now avoid direct-source checked iterator wrapper aliases while
preserving stream shape and checked behavior. This is reliability/ergonomics work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
