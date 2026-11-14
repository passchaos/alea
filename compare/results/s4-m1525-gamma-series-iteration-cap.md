# S4-M1525 Incomplete-Gamma Series Iteration Cap

Date: 2026-11-15

## Change

`gammaSeriesP` capped the power series at 300 iterations. For shapes near the
`a >= 1e4` Wilson-Hilferty switch the series converges slowly at the mean
`x = a`, so the cap truncated the result:

- `P(9999, 9999)` returned `0.499943829768`; the converged value is
  `0.501329874837` (error `-1.386e-3`).
- The series/continued-fraction boundary at `x = a + 1` jumped by
  `1.43e-3` because the series side was truncated while the continued
  fraction was accurate.

Iteration probe at `a = x = 9999`:

| series iterations | P(9999, 9999) |
| --- | --- |
| 300 | 0.499943829768 |
| 500 | 0.501329533088 |
| 1000 | 0.501329874837 |
| 2000 | 0.501329874837 |

Cross-checks: the continued fraction reaches `0.501329874833` within 300
iterations, and the Wilson-Hilferty fallback at `a = 10000.001` gives
`0.501329813723` (difference `6.1e-8`). Raising the series cap to 1000
iterations therefore matches all three methods to ~1e-7 and removes the
boundary jump.

This improves `gammaIncompleteP` / `gammaIncompleteQ`, `gammaCdf` /
`gammaQuantile`, the chi-squared/chi/Erlang/Maxwell helpers, and the
gamma-based Poisson and negative-binomial CDFs for shapes just below `1e4`.
It is a deterministic diagnostics accuracy change; no RNG stream is affected.

## Validation

- New unit test `gammaIncompleteP large shape resolves the mean` checks
  `P(9999, 9999) = 0.501329874837`, the continued-fraction side
  `P(9999, 10000) = 0.505319197905`, and the `a = 10000.001` fallback
  `0.501329813723`.
- `zig build test --summary all` passes 940/940 (native `alea-tests`
  919/919).
- `zig build distcheck` passes.

The aggregate `validate-all` refresh is tracked as the following milestone.
