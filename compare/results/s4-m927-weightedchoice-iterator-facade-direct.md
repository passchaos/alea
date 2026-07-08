# S4-M927 WeightedChoice Iterator Facade Direct Constructors

## Gap

Reusable `WeightedChoice` iterator facade constructors still routed through
direct-source iterator wrappers. The direct-source constructors were simple
wrappers around iterator construction, so facade constructors can build iterators
directly.

## Local `rand` Baseline

Local Rust `rand` weighted-choice iterator workflows construct repeated sampling
iterators over an RNG reference. Alea's reusable `WeightedChoice` exposes
Zig-native pointer, value, `usize` index, and compact `u32` index iterators; the
facade constructors should preserve stream shape without extra wrapper dispatch.

## Implementation

- `src/seq.zig` updates `WeightedChoice.valueIter` to construct the value iterator
  directly.
- `src/seq.zig` updates `WeightedChoice.indexIter` and `WeightedChoice.indexIterU32`
  to construct index iterators directly, preserving compact `u32` length
  validation.
- `src/seq.zig` updates `WeightedChoice.ptrIter` to construct the facade sample
  iterator directly.
- Focused tests cover facade/direct iterator stream shape.

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
readmecheck ok
toolingcheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M927 is closed for the current bar: reusable `WeightedChoice` iterator facade
constructors now avoid direct-source iterator wrapper aliases while preserving
stream shape. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
