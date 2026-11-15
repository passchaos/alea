# S4-M1578 Discrete Quantile Inversion Gates

Date: 2026-11-15

## Audit

A probe checked the discrete quantile definition
`CDF(k) >= q` and `CDF(k-1) < q` at `q = 1e-12, 1e-6, 0.5, 1-1e-6,
1-1e-12` for binomial (`(20,0.3)`, `(1e6,0.3)`, `(1e18,2e-17)`,
`(1e18,0.5)`), Poisson (`lambda = 5, 1e6, 1e18`), negative binomial,
geometric, hypergeometric, Zipf, and Zeta.

All cases satisfy the invariant except Poisson at `lambda = 1e18`: the
normal/`gammaIncompleteQ` fallback's `normCdf` absolute error (`~7.5e-8`)
exceeds the `~1e-14` PMF spacing there, so `CDF(k)` and `CDF(k-1)` are
identical in f64 and the strict discrete invariant is not resolvable. The
quantile itself remains about `1e-9` relative accurate. The existing
S4-M1527 gates cover `lambda <= 1e12`, where the invariant holds.

## Change

- `checkDiscrete` now gates the quantile inversion invariants for binomial,
  negative binomial, geometric, hypergeometric, Zipf, and Zeta at
  `q = 1e-6, 0.5, 1-1e-6` (`CDF(k) >= q`, `CDF(k-1) <= q`; the previous
  point is non-strict because the CDF can be flat within its approximation
  error).
- The Poisson huge-lambda gates from S4-M1527 remain the reference for that
  family.
- No library code, stream, or benchmark changed; the milestone is
  gate-only.

## Validation

- `zig build distcheck --summary all` passes 5/5 steps and 2/2 tests with
  the new gates.
- `zig build test --summary all` passes 960/960 tests (native `alea-tests`
  939/939).
