# S4-M718 Distribution Choose Checked Values

## Gap

Distribution-layer `Choose` has checked value arrays and owned values for
explicit empty-type error paths. Single-shot value copying still only had
infallible `sampleValue*`, leaving users without checked scalar value helpers for
uninhabited output types.

Distribution-layer `Choose` should expose checked scalar value helpers that
return an explicit error before random-stream use or value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes slice choice samplers returning references
over inhabited items. Alea's distribution-layer `Choose(T)` also exposes
value-copy helpers, so checked scalar value-copy APIs improve Zig-native
fallible workflows for uninhabited `T`.

## API Added

`src/distributions.zig` adds checked scalar value helpers to `Choose(T)`:

- `Choose(T).sampleValueChecked`
- `Choose(T).sampleValueCheckedFrom`
- `Choose(T).valueChecked`
- `Choose(T).valueCheckedFrom`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Empty enum-containing value types return `error.EmptyRange` before
  random-stream use or value copying.
- Habitable value types preserve the same stream shape as `sampleValueFrom`.

## Adoption and Documentation

- Focused distribution tests compare checked and unchecked scalar value sampling
  for stream-shape parity, and cover `Choose(Empty).sampleValueCheckedFrom` /
  `valueCheckedFrom` with zero stream consumption.
- Tests avoid `expectError` where the success payload contains an empty enum,
  preventing Zig's test formatter from trying to print impossible values.
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
toolingcheck ok
examplecheck ok
apicheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M718 is closed for the current bar: distribution-layer `Choose` now has
checked scalar value-copy helpers with empty-type failures before random-stream
use, value copying, or assertions. This is reliability/ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
