# S4-M905 Checked Index Facade Aliases Direct Paths

## Gap

After direct-source checked index helpers were made direct, facade
`sampleIndexChecked` and `sampleIndexU32Checked` helpers for `Choose`, `Choice`,
and `WeightedChoice` still routed through the corresponding `From` helpers. Facade
callers should get the same checked prevalidation and stream shape without an
extra direct-source wrapper alias.

## Local `rand` Baseline

Local Rust `rand` choice and weighted-index workflows sample indexes directly
through an RNG reference. Alea's facade helpers keep Zig-native `Rng` entry
points, and checked facade index sampling should execute the same direct
uniform-index or alias-table mapping as direct-source calls while preserving
checked errors.

## Implementation

- `src/distributions.zig` updates distribution-layer `Choose.sampleIndexChecked`
  and `Choose.sampleIndexU32Checked` to validate and sample indexes directly
  through the facade `Rng`.
- `src/seq.zig` applies the same direct checked facade index mapping to reusable
  `Choice`.
- `src/seq.zig` updates reusable `WeightedChoice.sampleIndexChecked` and
  `WeightedChoice.sampleIndexU32Checked` to sample the cached alias table directly
  through the facade `Rng`.
- Focused tests compare each facade helper against helper-generated indexes or
  direct table samples for stream shape while existing singleton and oversized-u32
  coverage preserves checked behavior.

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
toolingcheck ok
examplecheck ok
apicheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M905 is closed for the current bar: facade checked index helpers for
distribution `Choose`, reusable `Choice`, and reusable `WeightedChoice` now avoid
`sampleIndexCheckedFrom` / `sampleIndexU32CheckedFrom` wrapper aliases while
preserving stream shape and checked error behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
