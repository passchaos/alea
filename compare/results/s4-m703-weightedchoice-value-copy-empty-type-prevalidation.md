# S4-M703 WeightedChoice Value-Copy Empty-Type Prevalidation

## Gap

Reusable weighted choice iterator constructors now reject empty enum-containing
value types before building alias-table iterators. `WeightedChoice` value-copy
helpers could still attempt to copy sampled values into caller-owned or owned
value outputs for uninhabited `T`, especially in constant-weight paths.

`WeightedChoice` value-copy helpers should treat non-empty uninhabited value
outputs deterministically before allocation, random-stream use, or value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes weighted choice samplers that return
references over inhabited slice items. Rust's type flow avoids constructing
impossible output values, while Alea's `WeightedChoice(T, Weight)` also exposes
value-copy helpers for Zig-native workflows.

For Alea, infallible caller-owned value fill becomes a no-op for uninhabited
`T`, while allocation-returning value copies return `error.EmptyInput` before
allocating output storage.

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in:

- `WeightedChoice(T, Weight).fillValuesFrom`
- `WeightedChoice(T, Weight).valuesFrom`

Public wrappers `fillValues` and `values` inherit this behavior. Public
signatures are unchanged.

Deterministic behavior is explicit:

- Empty output/count requests still return before validating the value type.
- Non-empty empty enum-containing caller-owned fills are no-ops before
  random-stream use or value copying.
- Non-empty empty enum-containing owned value copies return `error.EmptyInput`
  before output allocation, random-stream use, or value copying.
- Pointer/index helpers and habitable value types keep existing behavior.

## Adoption and Documentation

- Focused seq tests cover `WeightedChoice(Empty, Weight).fillValuesFrom` and
  `valuesFrom` with a constant-weight table, proving no stream consumption and
  preallocation behavior with a failing allocator.
- Tests avoid `expectError` where the success payload contains an empty enum,
  preventing Zig's test formatter from trying to print impossible values.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq test:

```text
$ zig test src/seq.zig --test-filter "weighted choice sampler maps alias indexes to items"
1/2 seq.test.weighted choice sampler maps alias indexes to items...OK
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
roadmapcheck ok
examplecheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M703 is closed for the current bar: reusable `WeightedChoice` value-copy
helpers now handle empty enum-containing output types before allocation,
random-stream use, value copying, or assertions. This is reliability and
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
