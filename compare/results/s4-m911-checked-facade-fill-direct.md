# S4-M911 Checked Facade Fills Direct Paths

## Gap

Checked facade pointer/value/index fill helpers for distribution `Choose`,
reusable `Choice`, and reusable `WeightedChoice` still routed through direct-source
checked fill wrappers. Direct-source checked fills already had direct sampling
logic, so facade checked fills can execute the same loops directly while
preserving stream shape and prevalidation behavior.

## Local `rand` Baseline

Local Rust `rand` choice and weighted-choice workflows fill repeated samples by
looping over direct RNG draws. Alea's checked facade fills provide Zig-native
caller-owned buffers for pointer, value, and index outputs, and should fill those
buffers directly rather than dispatching through `From` wrappers.

## Implementation

- `src/distributions.zig` updates distribution-layer `Choose.fillChecked`,
  `fillValuesChecked`, and `fillIndicesChecked` to fill directly through the
  facade `Rng`.
- `src/seq.zig` applies the same direct checked facade fill structure to reusable
  `Choice`.
- `src/seq.zig` updates reusable `WeightedChoice` checked facade pointer/value/index
  fills to use the cached alias table directly through the facade `Rng`.
- Focused tests compare facade checked fills against direct-source checked fills
  for stream shape while existing empty-enum and singleton coverage preserves
  checked behavior.

## Validation

Focused distribution and sequence tests:

```text
$ zig test src/distributions.zig --test-filter "distribution Choose sampler mirrors slice choices"
1/2 distributions.test.distribution Choose sampler mirrors slice choices...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "weighted choice sampler maps alias indexes to items"
1/2 seq.test.weighted choice sampler maps alias indexes to items...OK
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
apicheck ok
examplecheck ok
readmecheck ok
```

## Result

S4-M911 is closed for the current bar: checked facade pointer/value/index fills for
distribution `Choose`, reusable `Choice`, and reusable `WeightedChoice` now avoid
direct-source checked fill wrapper aliases while preserving stream shape and
checked behavior. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
