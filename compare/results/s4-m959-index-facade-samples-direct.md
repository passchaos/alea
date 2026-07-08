# S4-M959 Index Facade Samples Direct Paths

## Gap

Non-checked facade index sample helpers for distribution-layer `Choose`, reusable
`Choice`, and reusable `WeightedChoice` still routed through direct-source
`From` wrappers. Checked facade index helpers were direct already; the unchecked
facade variants should also execute direct index sampling through their facade
`Rng` while preserving stream shape and compact-index validation.

## Local `rand` Baseline

Local Rust `rand` choice and weighted-index workflows sample indexes directly
through an RNG reference. Alea's facade helpers keep Zig-native `Rng` entry
points, and non-checked facade index sampling should avoid an extra direct-source
wrapper alias.

## Implementation

- `src/distributions.zig` updates `Choose.sampleIndex` and `sampleIndexU32` to
  sample uniform indexes directly through the facade `Rng`.
- `src/seq.zig` applies the same direct index mapping to reusable `Choice`.
- `src/seq.zig` updates reusable `WeightedChoice.sampleIndex` and
  `sampleIndexU32` to sample the cached alias table directly through the facade
  `Rng`.
- Focused tests compare facade helpers against helper-generated indexes or direct
  table samples for stream shape while preserving singleton and oversized-u32
  behavior.

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
toolingcheck ok
apicheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M959 is closed for the current bar: non-checked facade index helpers for
`Choose`, `Choice`, and `WeightedChoice` now avoid direct-source wrapper aliases
while preserving stream shape and compact-index validation. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
