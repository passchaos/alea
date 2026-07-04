# S4-M27 Rank Distributions Adoption Example

Date: 2026-07-04

Purpose: add runnable adoption guidance for rank/heavy-tail discrete distributions:
finite `Zipf`, unbounded `Zeta`, vector rank samplers, degenerate
infinite-exponent behavior, and checked invalid parameters.

## Change

Added `examples/rank_distributions.zig` and build step:

```sh
zig build run-rank-distributions
```

The example demonstrates:

- `Zipf(f64).init(n, exponent)` diagnostics, scalar sample, and `fillFrom`;
- `Zeta(f64).init(exponent)` diagnostics, scalar sample, and `fillFrom`;
- vector `VectorZipf` and `VectorZeta` lane-batch samples;
- infinite-exponent rank-one degeneracy for Zipf and Zeta;
- checked invalid `Zipf(n=0)` and `Zeta(exponent=1)` returning
  `InvalidParameter`.

## Validation

Command:

```sh
zig build run-rank-distributions
```

Result: passed and printed deterministic Zipf/Zeta outputs.

`zig build examples` includes this example, so `zig build validate` covers it
through the examples validation gate added in S4-M15.

## S4-M27 Decision

S4-M27 is closed for the current rank-distribution adoption bar: users now have
runnable guidance for finite and unbounded rank distributions in addition to API
docs, unit tests, distcheck, benchmarks, and parity notes.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
