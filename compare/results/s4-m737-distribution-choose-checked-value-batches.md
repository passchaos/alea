# S4-M737 Distribution Choose Checked Value Batches

## Gap

Reusable `Choice` and `WeightedChoice` now expose checked caller-owned and
allocation-returning value-copy batch aliases. Distribution-layer `Choose` still
only exposed unchecked names for those value-copy batch shapes, even though it
already had checked scalar values, fixed value arrays, and value iterators.

Distribution-layer `Choose` should provide checked value batch aliases that
return distribution-style errors before random-stream use, allocation, or value
copying for empty enum-containing value types.

## Local `rand` Baseline

The local Rust `rand` checkout exposes repeated choice workflows through
reference-oriented slice choice and iterator collection. Alea's distribution-layer
`Choose(T)` exceeds the reference-only shape with reusable value-copy fills and
owned batches; checked aliases make those value-copy batch paths explicit for
fallible Zig workflows involving uninhabited value types.

## API Added

`src/distributions.zig` adds checked value batch aliases to `Choose(T)`:

- `Choose(T).fillValuesChecked`
- `Choose(T).fillValuesCheckedFrom`
- `Choose(T).valuesChecked`
- `Choose(T).valuesCheckedFrom`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Checked value-fill aliases preserve `fillValuesFrom` stream shape for inhabited
  value types.
- Checked owned value aliases preserve `valuesFrom` stream shape for inhabited
  value types.
- Non-empty empty enum-containing value outputs return `error.EmptyRange` before
  random-stream use, allocation, or value copying.
- Zero-length checked fills and owned batches preserve existing no-consumption /
  zero-allocation-shape behavior.

## Adoption and Documentation

- Focused distribution tests compare checked and unchecked caller-owned value
  fills and owned value batches for stream parity.
- Empty-type tests cover `fillValuesCheckedFrom` and `valuesCheckedFrom`
  returning `error.EmptyRange` with zero stream consumption and no induced
  allocation failure.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "distribution Choose sampler mirrors slice choices"
1/2 distributions.test.distribution Choose sampler mirrors slice choices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

No output.

Broader native test gate:

```text
$ zig build test
readmecheck ok
roadmapcheck ok
examplecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M737 is closed for the current bar: distribution-layer `Choose` now has
checked aliases for caller-owned and allocation-returning value-copy batches.
This is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
