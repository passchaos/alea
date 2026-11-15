# S4-M1596 Von Mises CDF and Quantile

Date: 2026-11-15

## Feature

The circular von Mises distribution was the last core family with no
CDF/quantile diagnostics. Added:

- `vonMisesCdf(x, mu, kappa)` and `vonMisesQuantile(p, mu, kappa)`
  polymorphic peer-type helpers (f32/f64),
- `VonMises(T).cdf` and `VonMises(T).quantile` methods.

## Convention

The sampler returns `μ + δ` with `δ ∈ (-π, π]`, so the CDF is the periodic
relative CDF with its cut at `μ ± π`: `cdf(μ) = 0.5`, `cdf(μ + π) = 1`, and
`cdf(μ − π)` is the same point on the circle. The quantile returns
`μ + δ` in `(μ − π, μ + π]`; `quantile(0) = μ − π` and
`quantile(1) = μ + π`.

## Algorithm

For `κ <= 1e4` the exact Fourier–Bessel series

```
F(d) = (d+π)/(2π) + (1/π) Σ_{k≥1} (I_k(κ)/I₀(κ)) sin(kd)/k
```

is evaluated without allocation: the ratios follow the continued fraction
`ρ_{k−1} = 1/(2k/κ + ρ_k)` with `ρ_K = 0` (`K ≈ κ + 10√κ + 40`), the sum runs
downward from `K` (only `k <= 8.5√κ + 40` contributes), and the running ratio
and sum are rescaled together when the ratio exceeds `1e100`, so the
normalized sum `s/t` never overflows. For `κ > 1e4` the first-order uniform
asymptotic

```
F ≈ Φ(y) − (y³ + 3y)·φ(y)/(24κ),   y = √κ·d
```

is used.

The quantile is deterministic bisection (64 iterations on `[-π, π]`, below
the f64 resolution of the interval).

## Accuracy

- Series vs fine Simpson integration of `e^{κ(cos t −1)}`: max difference
  `~1e-14` for `κ ∈ {0.1, 1, 5, 20, 100}` over `x ∈ [-3, 3]`.
- Pinned reference values: `F(-2.5; 0.1) = 9.278794490455626e-2`,
  `F(-2.5; 1) = 3.179048369438034e-2`, `F(-1; 5) = 1.903795453185303e-2`,
  `F(-1; 20) = 1.036747132254767e-5`, `F(0.5; 5) = 8.586624818092983e-1`,
  `F(-0.03; 1e4) = 1.350562972623093e-3`,
  `F(-0.03; 1e5) = 1.194998168301089e-21`.
- At the `κ = 1e4` branch boundary the corrected normal matches the series to
  `4.6e-4` at `p ≈ 1.3e-12` (the series' own cancellation floor is `~1e-15`);
  for `κ = 1e5` the corrected normal is the accurate branch (the series
  cancellation floor dominates below `~1e-15`).
- Quantile round-trips at `p ∈ {1e-6, 0.1, 0.5, 0.9, 1−1e-6}` within `1e-9`
  for `κ ∈ {0.1, 1, 5, 20, 1e4, 1e5}`; f32 path and NaN parameter rejection.

## Documented Limits

- The series has a `~1e-15` absolute cancellation floor. S4-M1613 adds a
  local density-integral series near the `μ − π` antipode (see
  `s4-m1613-von-mises-antipode-tail.md`), which fixes the angle-near-antipode
  tail; the bulk-angle region for large `κ` (for example `κ = 50` at
  `p = 1e-12`) still uses the Fourier series and keeps its `~3e-5` relative
  floor.
- The `κ > 1e4` asymptotic's remaining tail error is `O((y⁴/κ)²)`: about
  `5e-4` at `κ = 1e4`, `p ≈ 1e-12`, and below `1e-8` for `κ >= 1e6`. The
  bulk error is `O(1/κ²)`.

## Validation

- New test `VonMises CDF and quantile are exact inverses` covers the
  symmetry/cut behavior, monotonicity on the open interval, reference values,
  quantile round-trips, the `κ = 0` uniform closed form, f32, and NaN paths.
- `zig build test distcheck --summary all` passes 966/966 tests (native
  945/945).
- Diagnostics-only change: no sampling stream, benchmark, or existing API
  behavior changed.
