# S4-M901 ValueChecked Alias Direct Sampling Paths

## Gap

`Choose.valueCheckedFrom`, `Choice.valueCheckedFrom`, and
`WeightedChoice.valueCheckedFrom` were still aliases through
`sampleValueCheckedFrom`, and the facade `valueChecked` helpers were aliases
through `sampleValueChecked`. After S4-M898 through S4-M900, the checked scalar
sample helpers were already direct, but the value alias layer still added another
wrapper before the same checked value mapping.

## Local `rand` Baseline

Local Rust `rand` slice-choice and weighted-choice workflows expose direct value
selection APIs over uniform or weighted sampled indexes. Alea intentionally keeps
Zig-native checked value aliases, and those aliases should preserve the same
prevalidation and stream shape without routing through an additional checked
sample wrapper.

## Implementation

- `src/distributions.zig` updates distribution-layer `Choose.valueChecked` and
  `Choose.valueCheckedFrom` so the alias performs checked direct uniform-index
  value sampling.
- `src/seq.zig` updates reusable `Choice.valueChecked` and `Choice.valueCheckedFrom`
  so the alias performs checked direct uniform-index value sampling.
- `src/seq.zig` updates reusable `WeightedChoice.valueChecked` and
  `WeightedChoice.valueCheckedFrom` so the alias performs checked direct
  `AliasTable` value sampling.
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
apicheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M901 is closed for the current bar: checked value aliases for distribution
`Choose`, reusable `Choice`, and reusable `WeightedChoice` now avoid
`sampleValueChecked` wrapper aliases after prevalidation while preserving stream
shape and checked error behavior. This is reliability/ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
