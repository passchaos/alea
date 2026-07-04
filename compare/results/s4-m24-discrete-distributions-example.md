# S4-M24 Discrete Distributions Adoption Example

Date: 2026-07-04

Purpose: add runnable adoption guidance for core discrete distributions,
including reusable samplers, bulk fills, geometric trial/failure semantics, vector
samplers, diagnostics, and checked invalid-parameter behavior.

## Change

Added `examples/discrete_distributions.zig` and build step:

```sh
zig build run-discrete-distributions
```

The example demonstrates:

- `Bernoulli` diagnostics, scalar sample, and bulk fill;
- `Binomial` diagnostics, scalar sample, and bulk fill;
- `NegativeBinomial` failure-count semantics;
- `Poisson` diagnostics, scalar sample, and bulk fill;
- `Geometric` trial-count semantics;
- `GeometricFailures` and `StandardGeometric` rand-style failure-count
  semantics;
- `Hypergeometric` diagnostics, scalar sample, and bulk fill;
- vector `VectorBinomial` and `VectorPoisson` lane-batch samples;
- checked invalid `Bernoulli(p=1.5)` returning `InvalidProbability`.

## Validation

Command:

```sh
zig build run-discrete-distributions
```

Result: passed and printed deterministic discrete-distribution outputs.

`zig build examples` includes this example, so `zig build validate` covers it
through the examples validation gate added in S4-M15.

## S4-M24 Decision

S4-M24 is closed for the current discrete-distribution adoption bar: users now
have runnable guidance for the main discrete families in addition to API docs,
unit tests, distcheck, benchmarks, and parity notes.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
