# S4-M926 Choice Iterator Facade Direct Constructors

## Gap

Reusable `Choice` iterator facade constructors still routed through direct-source
iterator wrappers. The direct-source constructors were simple wrappers around
iterator construction, so facade constructors can build iterators directly.

## Local `rand` Baseline

Local Rust `rand` slice-choice iterator workflows construct repeated sampling
iterators over an RNG reference. Alea's reusable `Choice` exposes Zig-native
pointer, value, `usize` index, and compact `u32` index iterators; the facade
constructors should preserve stream shape without extra wrapper dispatch.

## Implementation

- `src/seq.zig` updates `Choice.valueIter` to construct the value iterator
  directly.
- `src/seq.zig` updates `Choice.indexIter` and `Choice.indexIterU32` to construct
  index iterators directly, preserving compact `u32` length validation.
- `src/seq.zig` updates `Choice.ptrIter` to construct the facade sample iterator
  directly.
- Focused tests cover facade/direct iterator stream shape.

## Validation

Focused reusable Choice tests:

```text
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "Choice index iterators produce repeated indices"
1/3 seq.test.Choice index iterators produce repeated indices...OK
2/3 seq.test.WeightedChoice index iterators produce repeated indices...OK
3/3 root.test_0...OK
All 3 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
readmecheck ok
toolingcheck ok
apicheck ok
roadmapcheck ok
examplecheck ok
```

## Result

S4-M926 is closed for the current bar: reusable `Choice` iterator facade
constructors now avoid direct-source iterator wrapper aliases while preserving
stream shape. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
