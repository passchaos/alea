# S4-M21 Distribution Diagnostics Adoption Example

Date: 2026-07-04

Purpose: add runnable adoption guidance for constructor/accessor diagnostics,
derived parameterizations, support/moment reporting, z-score conversion, and
range-first PERT builders.

## Change

Added `examples/distribution_diagnostics.zig` and build step:

```sh
zig build run-distribution-diagnostics
```

The example demonstrates:

- `Normal(T).initMeanCv`, `fromZScore`, mean/stddev/variance accessors;
- `LogNormal(T).initMeanCv`, log-space and linear-space moment accessors;
- `Exponential(T)` inverse-rate, moment, median, and support diagnostics;
- `Gamma(T)` expected value, variance, mode, and sample;
- `Beta(T)` expected value, variance, optional mode, and sample;
- `Pert(T).initRange(...).withShape(...).withMean(...)` range-first builder;
- `Poisson` moments/support diagnostics.

It prints deterministic diagnostics and a short reminder to echo derived
parameters and support before sampling.

## Validation

Command:

```sh
zig build run-distribution-diagnostics
```

Result: passed and printed deterministic distribution diagnostics and samples.

`zig build examples` includes this example, so `zig build validate` covers it
through the examples validation gate added in S4-M15.

## S4-M21 Decision

S4-M21 is closed for the current diagnostics adoption bar: users now have
runnable guidance for moments, support, derived constructors, z-score conversion,
and PERT builders in addition to API docs and unit coverage.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
