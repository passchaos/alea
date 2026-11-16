# S4-M1741 Quantile Newton Sweep (Skew-Normal, Rice, Hoyt)

Date: 2026-11-16

## Change

Following S4-M1737/S4-M1739, replaced the remaining slow bisection quantiles
with the same safeguarded Newton pattern:

- `skewNormalQuantile`: standardized CDF `Φ(z) − 2T(z, α)` and density
  `2φ(z)Φ(αz)`, bracket `[-40, 40]`, normal-quantile start.
- `riceQuantile`: Rice density `x/σ² · exp(−(x²+ν²)/(2σ²)) · I₀(xν/σ²)`,
  normal start for `ν/σ > 200` and Rayleigh start for `ν = 0`; the density
  uses the same Gaussian mean/variance as the large-noncentrality CDF branch.
- `hoytQuantile`: density `2a x · (2q/(1+q²)) · exp(−a x²) · I₀(r a x²)` with
  `a = (1+q²)²/(4q²Ω)` and `r = (1−q²)/(1+q²)`, Rayleigh start.

All three keep a `[lo, hi]` bracket, fall back to the midpoint when Newton
leaves the bracket or the density is non-positive, and stop on `F(x) == p` or
when the relative bracket width is below `1e-12`.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216
"quantile"`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea skew-normal quantile` | 0.005 M/s | 0.056-0.062 M/s | ~11-12x |
| `alea rice quantile` | 0.018 M/s | 0.212-0.226 M/s | ~12x |
| `alea hoyt quantile` | 0.043 M/s | 0.535-0.576 M/s | ~12-13x |
| `alea ex-gaussian quantile` | 0.258-0.277 M/s | unchanged | baseline |
| `alea inverse-gaussian quantile` | 0.236-0.251 M/s | unchanged | baseline |

Checksums are unchanged for all three optimized rows (`2174.360`, `6230.417`,
`3474.856`), confirming the same outputs on the 1000-point p grid.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 985/985
  tests (native `alea-tests` 962/962).
- Existing tests cover skew-normal `p = 1e-9..1e-18` plus 0.1/0.5/0.9, Rice
  `ν = 0` Rayleigh and `(1, 1)` at p = 0.1/0.5/0.9, and Hoyt `q = 0.5/1` at
  p = 0.1/0.5/0.9.
- Follow-up: S4-M1742 refreshes `validate-all`.
