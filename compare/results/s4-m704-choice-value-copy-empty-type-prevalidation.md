# S4-M704 Choice Value-Copy Empty-Type Prevalidation

## Gap

Reusable `WeightedChoice` value-copy helpers now handle empty enum-containing
output types before allocation or value copying. The unweighted reusable
`Choice(T)` sampler had the same value-copy hazard: `fillValuesFrom` and
`valuesFrom` could attempt to copy sampled values for uninhabited `T`.

`Choice` value-copy helpers should treat non-empty uninhabited value outputs
deterministically before allocation, random-stream use, or value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes slice choice samplers that return
references over inhabited items. Rust's type flow avoids constructing impossible
output values, while Alea's `Choice(T)` also exposes value-copy helpers for
Zig-native workflows.

For Alea, infallible caller-owned value fill becomes a no-op for uninhabited
`T`, while allocation-returning value copies return `error.EmptyInput` before
allocating output storage.

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in:

- `Choice(T).fillValuesFrom`
- `Choice(T).valuesFrom`

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

- Focused seq tests cover `Choice(Empty).fillValuesFrom` and `valuesFrom`,
  proving no stream consumption and preallocation behavior with a failing
  allocator.
- Tests avoid `expectError` where the success payload contains an empty enum,
  preventing Zig's test formatter from trying to print impossible values.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq test:

```text
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
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

S4-M704 is closed for the current bar: reusable `Choice` value-copy helpers now
handle empty enum-containing output types before allocation, random-stream use,
value copying, or assertions. This is reliability and ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
