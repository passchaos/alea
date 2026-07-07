# S4-M707 Distribution Choose Value-Copy Empty-Type Prevalidation

## Gap

Reusable `seq.Choice` value-copy helpers now handle empty enum-containing output
types before allocation or value copying. The distribution-layer `Choose(T)`
sampler had the same caller-owned value-copy hazard in `fillValuesFrom`, where a
non-empty uninhabited destination could reach impossible value-copying paths.

`distributions.Choose(T).fillValuesFrom` should treat non-empty uninhabited value
outputs deterministically before random-stream use or value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes distribution/slice choice samplers that
return references over inhabited items. Rust's type flow avoids constructing
impossible output values, while Alea's distribution-layer `Choose(T)` also
exposes value-copy helpers for Zig-native workflows.

For Alea, infallible caller-owned value fill becomes a no-op for uninhabited
`T`.

## API Changed

`src/distributions.zig` now prevalidates empty enum-containing value types in:

- `Choose(T).fillValuesFrom`

Public wrapper `fillValues` inherits this behavior. Public signatures are
unchanged.

Deterministic behavior is explicit:

- Empty output requests still return before validating the value type.
- Non-empty empty enum-containing caller-owned fills are no-ops before
  random-stream use or value copying.
- Pointer/reference helpers and habitable value types keep existing behavior.

## Adoption and Documentation

- Focused distribution tests cover `Choose(Empty).fillValuesFrom`, proving no
  stream consumption for a non-empty empty enum destination.
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
toolingcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M707 is closed for the current bar: distribution-layer `Choose` value-copy
fills now handle empty enum-containing output types before random-stream use,
value copying, or assertions. This is reliability and ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
