# S4-M709 Distribution Choose Owned Values

## Gap

Distribution-layer `Choose` now has caller-owned and fixed-size value outputs.
It still lacked an allocation-returning value batch helper, forcing users to
allocate and fill manually for owned repeated distribution choices.

Distribution-layer `Choose` should offer owned repeated value outputs with the
same empty-type prevalidation behavior as its caller-owned/fixed-size value
helpers.

## Local `rand` Baseline

The local Rust `rand` checkout exposes distribution/slice choice workflows that
can be collected into owned containers. Alea's distribution-layer `Choose(T)` can
provide Zig-native allocator-returning value batches directly.

For Alea, owned value batches return `error.EmptyRange` for non-zero uninhabited
value types before output allocation, random-stream use, or value copying.

## API Added

`src/distributions.zig` adds owned value helpers to `Choose(T)`:

- `Choose(T).values`
- `Choose(T).valuesFrom`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Zero-count owned values return an empty allocation before validating the value
  type.
- Non-zero empty enum-containing owned value batches return `error.EmptyRange`
  before output allocation, random-stream use, or value copying.
- Habitable value types use the existing value-fill behavior and stream shape.

## Adoption and Documentation

- Focused distribution tests compare owned value output against `fillValuesFrom`,
  and cover `Choose(Empty).valuesFrom` with a failing allocator to prove
  preallocation behavior and zero stream consumption.
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
examplecheck ok
apicheck ok
roadmapcheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M709 is closed for the current bar: distribution-layer `Choose` now has owned
repeated value helpers with empty-type failures before allocation,
random-stream use, value copying, or assertions. This is reliability and
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
