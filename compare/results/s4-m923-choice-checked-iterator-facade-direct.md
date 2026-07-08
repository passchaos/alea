# S4-M923 Choice Checked Iterator Facade Direct Constructors

## Gap

Reusable `Choice` checked iterator facade constructors still routed through
direct-source checked iterator wrappers. The direct-source checked constructors
were simple wrappers around iterator construction, so facade checked constructors
can build the iterator directly after any required prevalidation.

## Local `rand` Baseline

Local Rust `rand` slice-choice iterator workflows construct repeated sampling
iterators over an RNG reference. Alea's reusable `Choice` exposes Zig-native
pointer, value, `usize` index, and compact `u32` index iterators; the checked
facade constructors should preserve validation and stream shape without extra
wrapper dispatch.

## Implementation

- `src/seq.zig` updates `Choice.valueIterChecked` to keep empty-enum prevalidation
  and then construct the value iterator directly.
- `src/seq.zig` updates `Choice.indexIterChecked` and `Choice.indexIterU32Checked`
  to construct index iterators directly, preserving compact `u32` length
  validation.
- `src/seq.zig` updates pointer `iterChecked` and `ptrIterChecked` aliases to
  construct facade sample iterators directly.
- Focused tests cover facade/direct checked iterator stream shape.

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
examplecheck ok
apicheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M923 is closed for the current bar: reusable `Choice` checked iterator facade
constructors now avoid direct-source checked iterator wrapper aliases while
preserving stream shape and checked behavior. This is reliability/ergonomics work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
