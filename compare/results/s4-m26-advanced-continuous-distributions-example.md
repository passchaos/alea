# S4-M26 Advanced Continuous Distributions Adoption Example

Date: 2026-07-04

Purpose: add runnable adoption guidance for advanced continuous shape/tail
families not covered by the core continuous example, including optional moments,
bulk fills, vector samplers, and checked invalid-parameter behavior.

## Change

Added `examples/advanced_continuous_distributions.zig` and build step:

```sh
zig build run-advanced-continuous-distributions
```

The example demonstrates:

- `HalfNormal`, `ChiSquared`, `Chi`, `Erlang`, and `Maxwell` diagnostics and
  sampling;
- `LogLogistic`, `Kumaraswamy`, `PowerFunction`, `Gumbel`, and `Frechet`
  shape/tail diagnostics and sampling;
- `SkewNormal`, `InverseGaussian`, and `NormalInverseGaussian` diagnostics and
  sampling;
- `SkewNormal.fillFrom` bulk fill;
- vector `VectorChi` and `VectorSkewNormal` lane-batch samples;
- checked invalid `NormalInverseGaussian(alpha=1,beta=2)` returning
  `InvalidParameter`.

## Validation

Command:

```sh
zig build run-advanced-continuous-distributions
```

Result: passed and printed deterministic advanced continuous-distribution
outputs.

`zig build examples` includes this example, so `zig build validate` covers it
through the examples validation gate added in S4-M15.

## S4-M26 Decision

S4-M26 is closed for the current advanced-continuous adoption bar: users now have
runnable guidance for remaining advanced continuous families in addition to API
docs, unit tests, distcheck, benchmarks, and parity notes.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
