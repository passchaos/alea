# S4-M904 SampleValueChecked Facade Aliases Direct Paths

## Gap

After S4-M898 through S4-M901, direct-source checked value sampling and
`valueChecked` aliases were direct, but facade `sampleValueChecked` helpers for
`Choose`, `Choice`, and `WeightedChoice` still routed through
`sampleValueCheckedFrom`. Facade callers should get the same checked
prevalidation and stream shape without an extra direct-source wrapper alias.

## Local `rand` Baseline

Local Rust `rand` choice and weighted-choice APIs expose value selection directly
through the RNG reference. Alea's facade helpers keep the Zig-native `Rng` facade
surface, and checked facade value sampling should execute the same direct mapping
as direct-source calls while preserving checked errors.

## Implementation

- `src/distributions.zig` updates distribution-layer `Choose.sampleValueChecked`
  to validate and sample a uniform index directly through the facade `Rng`.
- `src/seq.zig` updates reusable `Choice.sampleValueChecked` with the same direct
  checked uniform-index mapping.
- `src/seq.zig` updates reusable `WeightedChoice.sampleValueChecked` to sample the
  cached alias table directly through the facade `Rng` and map into item storage.
- Focused tests compare each facade helper against helper-generated indexes or
  direct table samples for stream shape while existing empty-enum checks continue
  to cover no-consume checked prevalidation behavior.

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
roadmapcheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M904 is closed for the current bar: facade `sampleValueChecked` helpers for
distribution `Choose`, reusable `Choice`, and reusable `WeightedChoice` now avoid
`sampleValueCheckedFrom` wrapper aliases while preserving stream shape and checked
error behavior. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
