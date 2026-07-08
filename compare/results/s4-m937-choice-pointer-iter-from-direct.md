# S4-M937 Choice Pointer Iterator From Direct Constructor

## Gap

Reusable `Choice.ptrIterFrom` still routed through the generic direct-source
`iterFrom` alias. Both helpers construct the same pointer sample iterator, so the
pointer-specific direct-source constructor can build the iterator directly and
avoid another alias hop while preserving stream shape.

## Local `rand` Baseline

Local Rust `rand` slice-choice iterator workflows repeatedly sample references
from an RNG-backed slice iterator. Alea's reusable `Choice` keeps both `iterFrom`
and the Zig-native pointer alias `ptrIterFrom`; the pointer alias should be a
first-class direct-source constructor rather than a wrapper around another alias.

## Implementation

- `src/seq.zig` updates `Choice.ptrIterFrom` to call
  `Rng.sampleIterFrom(source, *const T, self)` directly.
- Focused tests compare pointer iterator aliases with regular iterators and
  verify index iterator stream shape remains unchanged.

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
apicheck ok
readmecheck ok
toolingcheck ok
roadmapcheck ok
examplecheck ok
```

## Result

S4-M937 is closed for the current bar: reusable `Choice.ptrIterFrom` now avoids
routing through `iterFrom` while preserving stream shape. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
