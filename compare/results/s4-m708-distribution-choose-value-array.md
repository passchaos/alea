# S4-M708 Distribution Choose Value Array

## Gap

Distribution-layer `Choose` value-copy fills now handle empty enum-containing
outputs. Unlike reusable `seq.Choice`, distribution-layer `Choose` did not expose
fixed-size value array helpers, leaving users to allocate temporary buffers or
manually fill arrays for repeated distribution choices.

Distribution-layer `Choose` should offer fixed-size value arrays, including a
checked variant with an explicit empty-type error path.

## Local `rand` Baseline

The local Rust `rand` checkout exposes distribution/slice choice samplers that
return references over inhabited items. Alea's distribution-layer `Choose(T)` is a
Zig-native sampler and can provide stack-friendly fixed-size value arrays while
preserving deterministic empty-type behavior.

For Alea, checked fixed-size value arrays return `error.EmptyRange` for non-zero
uninhabited value types before random-stream use or value copying.

## API Added

`src/distributions.zig` adds fixed-size value array helpers to `Choose(T)`:

- `Choose(T).valueArray`
- `Choose(T).valueArrayFrom`
- `Choose(T).valueArrayChecked`
- `Choose(T).valueArrayCheckedFrom`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Zero-size checked arrays return immediately before validating the value type.
- Non-zero empty enum-containing value arrays return `error.EmptyRange` before
  random-stream use or value copying.
- Habitable value types use the existing value-fill behavior and stream shape.

## Adoption and Documentation

- Focused distribution tests compare checked arrays against `fillValuesFrom`, and
  cover `Choose(Empty).valueArrayCheckedFrom` for non-zero `error.EmptyRange`,
  zero-size success, and zero stream consumption.
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
readmecheck ok
examplecheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M708 is closed for the current bar: distribution-layer `Choose` now has
fixed-size value array helpers, including checked empty-type failures before
random-stream use, value copying, or assertions. This is reliability and
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
