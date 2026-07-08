# S4-M938 WeightedChoice Pointer Iterator From Direct Constructor

## Gap

Reusable `WeightedChoice.ptrIterFrom` still routed through the generic
direct-source `iterFrom` alias. Both helpers construct the same pointer sample
iterator, so the pointer-specific direct-source constructor can build the
iterator directly and avoid another alias hop while preserving stream shape.

## Local `rand` Baseline

Local Rust `rand` weighted-choice iterator workflows repeatedly sample references
from an RNG-backed weighted sampler. Alea's reusable `WeightedChoice` keeps both
`iterFrom` and the Zig-native pointer alias `ptrIterFrom`; the pointer alias
should be a first-class direct-source constructor rather than a wrapper around
another alias.

## Implementation

- `src/seq.zig` updates `WeightedChoice.ptrIterFrom` to call
  `Rng.sampleIterFrom(source, *const T, self)` directly.
- Focused tests compare pointer iterator aliases with regular iterators and
  verify weighted index iterator stream shape remains unchanged.

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
apicheck ok
examplecheck ok
readmecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M938 is closed for the current bar: reusable `WeightedChoice.ptrIterFrom` now
avoids routing through `iterFrom` while preserving stream shape. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
