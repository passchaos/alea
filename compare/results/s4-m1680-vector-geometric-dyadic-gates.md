# S4-M1680 Vector Geometric Dyadic Probability Gates

Date: 2026-11-16

## Change

The vector geometric pmf gate only covered `p = 0.25` (`m = 2, k = 1`). The
dyadic packed-word kernel also has `m = 1`, `m = 2, k = 3`, `m = 3, k = 1`,
`m = 3, k = 3`, and `m = 4` mask branches, reached by `p = 0.5`, `0.75`,
`0.125`, `0.375`, and `0.0625`. Generalized
`checkVectorGeometricBins(rng, vectors, p, label)` and added gates for all six
dyadic probabilities. Tooling-only; no library code changed.

## Supporting Audit

A scratch 200k-sample sweep compared empirical CDFs with the exact sampler
CDFs for Zipf (exponents 1.25/1.5/2/3), Poisson (lambda 0.5/1/3/11.9),
binomial (p 0.125/0.375/0.4/0.6), geometric (p 0.125/0.375/0.4/0.9),
negative-binomial (p 0.25/0.4/0.5/0.9), and hypergeometric (100/30/10 and
1000/400/50). The largest deviations were about 0.0033 at 200k samples; 1M
sample reruns of the worst cases (Poisson lambda=1 and geometric p=0.375)
gave 0.00027-0.00089 across three seeds, consistent with sampling noise.

## Validation

- `zig build distcheck --summary all`: 5/5 steps and 2/2 tests with the six
  dyadic geometric gates.
- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native 950/950).

## Changed Files

- `tools/distcheck.zig`: parameterized vector geometric pmf gate and the six
  dyadic probability calls.
