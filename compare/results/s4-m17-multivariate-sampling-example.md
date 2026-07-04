# S4-M17 Multivariate Sampling Adoption Example

Date: 2026-07-04

Purpose: add runnable adoption guidance for multivariate sampling APIs, especially
the allocation-returning vs caller-owned-buffer vs flat batch shapes.

## Change

Added `examples/multivariate_sampling.zig` and build step:

```sh
zig build run-multivariate-sampling
```

The example demonstrates:

- `Multinomial.init`, expected-count diagnostics, allocation-returning
  `sampleFrom`, caller-owned `sampleIntoFrom`, and flat batched
  `sampleManyIntoFrom`;
- `Dirichlet(f64).init`, mean diagnostics, allocation-returning `sampleFrom`,
  caller-owned `sampleIntoFrom`, and flat batched `sampleManyIntoFrom`;
- a degenerate single-infinite-alpha Dirichlet vertex sample.

It prints deterministic samples and states when to use owned results,
caller-owned buffers, and flat batched outputs.

## Validation

Command:

```sh
zig build run-multivariate-sampling
```

Result: passed and printed deterministic Multinomial/Dirichlet outputs with
simple sum checks.

`zig build examples` includes this example, so `zig build validate` covers it
through the examples validation gate added in S4-M15.

## S4-M17 Decision

S4-M17 is closed for the current multivariate adoption bar: Multinomial and
Dirichlet users now have runnable guidance in addition to API docs, diagnostics,
unit tests, and distcheck coverage.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
