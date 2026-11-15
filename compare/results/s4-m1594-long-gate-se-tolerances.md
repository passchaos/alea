# S4-M1594 Standard-Error-Scaled Long-Run Directional Gates

Date: 2026-11-15

## Motivation

The long-run directional gates used fixed tolerances (`±0.002` to `±0.005`)
regardless of the sample count. At the 1e9-sample bar the standard error of a
mean is about `1e-5` for a `[0, 1]` quantity, so those gates were 30-150x
looser than the data and could not detect a bias below ~0.3%.

## Change

Added `longMeanTolerance(variance, samples, fixed)`:

```
tol = min(fixed, 6·sqrt(variance / samples) + 1e-12)
```

The `min` keeps the historical fixed tolerance for small sample counts and
tightens as the sample count grows. Applied to the i.i.d. directional gates:

- Kent mean resultant (`variance = dist.varianceAt(2)`) and the `x0²`/`x1²`
  second-moment gates (`variance <= 1/4`),
- Bingham `x0²` and vector Bingham `x0²` (`<= 1/4`),
- vMF and vector vMF mean resultant (`<= 1/4`),
- scalar and vector Watson `cos²` (`<= 1/4`),
- vector Kent mean resultant (`<= 1/4`),
- matrix Fisher O(3) determinant frequency (`variance = p(1-p)`).

At 1e9 samples the `[0, 1]` gates now use `6·sqrt(0.25/1e9) = 9.49e-5`
instead of `0.003`, and the determinant-frequency gate the same `9.49e-5`
instead of `0.005`. The Gibbs matrix-vMF gates keep their fixed `±0.02`
tolerance because the chain draws are autocorrelated and the effective sample
size is much smaller than `samples`.

## Validation

- `alea-distcheck --long 10000000` passes in 13.8 s.
- `alea-distcheck --long 1000000000` prints
  `distlongcheck ok (1000000000 samples)` in about 25 minutes; all tightened
  directional gates pass.
- The run reproduces the S4-M1589 non-directional values:
  `binomial(4)=0.237505`, `gamma(3)=0.450579`, normal tail `0.002698`,
  student-t tail `0.030104`, Gaussian copula `0.001875`, huge
  hypergeometric `below=0.252478 (cdf 0.252492)`.
- Tooling-only change: no library code, sampling stream, public API, or
  benchmark changed.

## Effect

The long-run directional evidence now proves the exact truncated-exponential
vMF/Kent marginal, the scalar-per-lane vector vMF, the vector Kent
uniform-angle branch, and the Bingham/Watson samplers hold their analytic
moments to roughly `1e-4` at 1e9 samples, instead of the former `~3e-3` bar.
