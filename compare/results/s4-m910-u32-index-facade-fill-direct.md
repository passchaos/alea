# S4-M910 U32 Index Facade Fills Direct Paths

## Gap

Facade `fillIndicesU32` helpers for distribution `Choose`, reusable `Choice`, and
reusable `WeightedChoice` still routed through direct-source `fillIndicesU32From`
wrappers. Direct-source compact index fills were already direct; facade fills can
execute the same u32 fill logic directly while preserving stream shape.

## Local `rand` Baseline

Local Rust `rand` choice and weighted-index workflows fill repeated samples by
looping over direct RNG draws. Alea's facade compact index fills keep Zig-native
caller-owned buffers, and should perform direct per-slot index filling without an
extra wrapper dispatch.

## Implementation

- `src/distributions.zig` updates distribution-layer `Choose.fillIndicesU32` to
  validate compact output size and fill indexes directly through the facade `Rng`.
- `src/seq.zig` applies the same direct uniform-index fill to reusable `Choice`.
- `src/seq.zig` updates reusable `WeightedChoice.fillIndicesU32` to call the
  cached alias table's compact fill directly through the facade `Rng`.
- Focused distribution and sequence tests compare facade fills against
  direct-source fills for stream shape.

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
examplecheck ok
readmecheck ok
apicheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M910 is closed for the current bar: facade compact index fills for distribution
`Choose`, reusable `Choice`, and reusable `WeightedChoice` now avoid direct-source
fill wrapper aliases while preserving stream shape and checked behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
