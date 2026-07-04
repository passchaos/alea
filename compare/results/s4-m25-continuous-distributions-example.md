# S4-M25 Continuous Distributions Adoption Example

Date: 2026-07-04

Purpose: add runnable adoption guidance for core continuous shape/tail
distributions, including reusable samplers, diagnostics, bulk fills, vector lane
batches, optional/undefined moments, and checked invalid-parameter behavior.

## Change

Added `examples/continuous_distributions.zig` and build step:

```sh
zig build run-continuous-distributions
```

The example demonstrates:

- `Gamma` diagnostics and sampling;
- `Beta` diagnostics, optional mode, scalar sampling, and `fillFrom`;
- `FisherF` optional moments;
- `StudentT` optional moments;
- `Triangular` and `Arcsine` median/moment diagnostics;
- `Cauchy` undefined mean handling;
- `Laplace` and `Logistic` diagnostics;
- `Rayleigh`, `Pareto`, and `Weibull` tail/shape diagnostics;
- `VectorGamma` lane-batch sampling;
- checked invalid `Weibull(scale=1, shape=0)` returning `InvalidParameter`.

## Validation

Command:

```sh
zig build run-continuous-distributions
```

Result: passed and printed deterministic continuous-distribution outputs.

`zig build examples` includes this example, so `zig build validate` covers it
through the examples validation gate added in S4-M15.

## S4-M25 Decision

S4-M25 is closed for the current continuous-distribution adoption bar: users now
have runnable guidance for core continuous shape/tail families in addition to API
docs, unit tests, distcheck, benchmarks, and parity notes.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
