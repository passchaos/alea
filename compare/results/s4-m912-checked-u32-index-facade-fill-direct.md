# S4-M912 Checked U32 Index Facade Fills Direct Paths

## Gap

Checked facade compact index fill helpers (`fillIndicesU32Checked`) for
distribution `Choose`, reusable `Choice`, and reusable `WeightedChoice` still
routed through direct-source checked compact fill wrappers. S4-M910 made the
unchecked compact facade fills direct; the checked compact facade variants should
also fill directly while preserving validation and stream shape.

## Local `rand` Baseline

Local Rust `rand` choice and weighted-index workflows fill repeated samples by
looping over direct RNG draws. Alea's checked facade compact index fills provide
Zig-native caller-owned `u32` buffers and should execute direct per-slot compact
index filling without wrapper dispatch.

## Implementation

- `src/distributions.zig` updates distribution-layer `Choose.fillIndicesU32Checked`
  to validate compact output size and fill indexes directly through the facade
  `Rng`.
- `src/seq.zig` applies the same direct checked compact index fill to reusable
  `Choice`.
- `src/seq.zig` updates reusable `WeightedChoice.fillIndicesU32Checked` to call
  the cached alias table's compact fill directly through the facade `Rng`.
- Focused distribution and sequence tests compare facade checked compact fills
  against direct-source checked compact fills for stream shape.

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
readmecheck ok
roadmapcheck ok
toolingcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M912 is closed for the current bar: checked facade compact index fills for
distribution `Choose`, reusable `Choice`, and reusable `WeightedChoice` now avoid
direct-source checked compact fill wrapper aliases while preserving stream shape
and checked behavior. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
