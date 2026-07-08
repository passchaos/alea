# S4-M961 ValueChecked Facade Direct Refresh

## Gap

A current-code audit found `valueChecked` facade helpers for distribution-layer
`Choose`, reusable `Choice`, and reusable `WeightedChoice` routing through
`valueCheckedFrom(rng)` again. Regardless of earlier milestones, the actual
current facade aliases should perform checked value sampling directly through the
facade `Rng` while preserving no-consume prevalidation and stream shape.

## Local `rand` Baseline

Local Rust `rand` slice-choice and weighted-choice workflows expose direct value
selection over RNG references. Alea intentionally keeps Zig-native checked value
aliases, and facade aliases should not require a direct-source wrapper hop.

## Implementation

- `src/distributions.zig` updates `Choose.valueChecked` to perform checked direct
  uniform-index value sampling through the facade `Rng`.
- `src/seq.zig` updates reusable `Choice.valueChecked` with the same checked
  direct uniform-index value mapping.
- `src/seq.zig` updates reusable `WeightedChoice.valueChecked` to sample the
  cached `AliasTable` directly through the facade `Rng` and map into item storage.
- Focused tests compare each alias with helper/direct table sampling for stream
  shape while existing empty-enum checks continue to prove no-consume checked
  prevalidation behavior.

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
examplecheck ok
roadmapcheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M961 is closed for the current bar: checked value facade aliases now match the
actual direct-path intent in the current codebase while preserving stream shape
and checked behavior. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
