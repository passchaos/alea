# S4-M1749 ExGaussian and InverseGaussian Newton Quantile

Date: 2026-11-16

## Change

Both quantiles used 100 bisection iterations on their CDFs. Replaced them with
the same safeguarded Newton pattern:

- InverseGaussian: normal-approximation start
  `mean + sqrt(mean³/shape)·probit(p)`, log-form density
  `sqrt(shape/(2πx³))·exp(−shape(x−mean)²/(2·mean²·x))`.
- ExGaussian: normal start `mu + spread·probit(p)`, density
  `(1/τ)·exp(0.5(σ/τ)² − (x−μ)/τ)·Φ((x−μ−σ²/τ)/σ)` using `normLogCdf`, and
  the shifted-exponential density for `sigma = 0`.

Both keep the bracket expansion, fall back to the midpoint when Newton leaves
the bracket or the density is non-finite, stop on `F(x) == p` or when the
relative bracket width is below `1e-12`, and return the converged point.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216
"quantile"`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea ex-gaussian quantile` | 0.269 M/s | 2.639 M/s | 9.8x |
| `alea inverse-gaussian quantile` | 0.247 M/s | 3.013 M/s | 12.2x |

Checksums are unchanged (`3883.020`, `4025.365`); the other quantile rows are
unchanged within noise.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 985/985
  tests (native `alea-tests` 962/962).
- Existing ExGaussian and InverseGaussian quantile tests (known values,
  p = 0.1/0.5/0.9, and the `sigma = 0`/shape edges) pass.
- Follow-up: S4-M1750 refreshes `validate-all`.
