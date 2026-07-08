# S4-M929 Choice Checked Iterator From Direct Constructors

## Gap

Reusable `Choice` direct-source checked iterator constructors still routed through
unchecked direct-source iterator wrappers. The unchecked constructors are simple
iterator construction helpers, so checked direct-source constructors can build
iterators directly after any required prevalidation.

## Local `rand` Baseline

Local Rust `rand` slice-choice iterator workflows construct repeated sampling
iterators over an RNG reference. Alea's reusable `Choice` exposes Zig-native
pointer, value, `usize` index, and compact `u32` direct-source iterators; the
checked direct-source constructors should preserve validation and stream shape
without extra wrapper dispatch.

## Implementation

- `src/seq.zig` updates `Choice.valueIterCheckedFrom` to keep empty-enum
  prevalidation and then construct the value iterator directly.
- `src/seq.zig` updates `Choice.indexIterCheckedFrom` and
  `Choice.indexIterU32CheckedFrom` to construct index iterators directly,
  preserving compact `u32` length validation.
- `src/seq.zig` updates pointer `iterCheckedFrom` and `ptrIterCheckedFrom` aliases
  to construct direct-source sample iterators directly.
- Focused tests cover checked direct-source iterator stream shape.

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
toolingcheck ok
roadmapcheck ok
readmecheck ok
apicheck ok
```

## Result

S4-M929 is closed for the current bar: reusable `Choice` checked direct-source
iterator constructors now avoid unchecked direct-source iterator wrapper aliases
while preserving stream shape and checked behavior. This is reliability/ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
