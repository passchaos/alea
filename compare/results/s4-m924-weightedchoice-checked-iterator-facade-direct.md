# S4-M924 WeightedChoice Checked Iterator Facade Direct Constructors

## Gap

Reusable `WeightedChoice` checked iterator facade constructors still routed
through direct-source checked iterator wrappers. The direct-source checked
constructors were simple wrappers around iterator construction, so facade checked
constructors can build the iterator directly after any required prevalidation.

## Local `rand` Baseline

Local Rust `rand` weighted-choice iterator workflows construct repeated sampling
iterators over an RNG reference. Alea's reusable `WeightedChoice` exposes
Zig-native pointer, value, `usize` index, and compact `u32` index iterators; the
checked facade constructors should preserve validation and stream shape without
extra wrapper dispatch.

## Implementation

- `src/seq.zig` updates `WeightedChoice.valueIterChecked` to keep empty-enum
  prevalidation and then construct the value iterator directly.
- `src/seq.zig` updates `WeightedChoice.indexIterChecked` and
  `WeightedChoice.indexIterU32Checked` to construct index iterators directly,
  preserving compact `u32` length validation.
- `src/seq.zig` updates pointer `iterChecked` and `ptrIterChecked` aliases to
  construct facade sample iterators directly.
- Focused tests cover facade/direct checked iterator stream shape.

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
toolingcheck ok
examplecheck ok
readmecheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M924 is closed for the current bar: reusable `WeightedChoice` checked iterator
facade constructors now avoid direct-source checked iterator wrapper aliases while
preserving stream shape and checked behavior. This is reliability/ergonomics work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
