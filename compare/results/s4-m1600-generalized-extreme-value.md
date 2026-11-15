# S4-M1600 Generalized Extreme Value Distribution

Date: 2026-11-15

## Feature

Added the Generalized Extreme Value (GEV) distribution, the block-maxima
limit law of extreme value theory and the counterpart of the existing
peaks-over-threshold `GeneralizedPareto`; absent from local Rust
`rand_distr`.

- `GeneralizedExtremeValue(T)` with `init`/`new`, location/scale/shape
  accessors, `expectedValue`/`varianceValue` (`?T` for divergent moments),
  `medianValue`/`modeValue`, `minValue`/`maxValue` (`?T` for unbounded
  sides), `cdf`/`quantile`, and `sample`/`sampleFrom`/`fill`/`fillFrom`;
- scalar free-function family (`generalizedExtremeValue*`,
  `fillGeneralizedExtremeValue*`, `generalizedExtremeValueCdf`/
  `generalizedExtremeValueQuantile`);
- vector family (`VectorGeneralizedExtremeValue`,
  `vectorGeneralizedExtremeValue*`, `fillVectorGeneralizedExtremeValue*`);
- `GeneralizedExtremeValueError` alias.

## Algorithms

- Sampling: one `Exp(1)` draw `E = −ln U` and the inverse CDF
  `x = μ + σ·expm1(−ξ·ln E)/ξ` for `ξ ≠ 0`, `x = μ − σ·ln E` for `ξ = 0`;
  `expm1` keeps small `|ξ|` accurate. The vector path draws a SIMD `Exp(1)`
  vector and applies the same inversion per lane.
- CDF: `exp(−(1+ξ(x−μ)/σ)^{−1/ξ})` with the Gumbel limit at `ξ = 0`;
  support sides return 0/1 for `ξ > 0`/`ξ < 0` respectively, and `±∞` are
  handled explicitly.
- Quantile: `μ + σ·expm1(−ξ·ln E)/ξ` with `E = −ln p` computed as
  `−log1p(p−1)` so both tails stay accurate; `p = 0`/`p = 1` return the
  finite support bound where one exists and `∓∞` otherwise.
- Moments: `μ + σ(Γ(1−ξ)−1)/ξ` and `σ²(Γ(1−2ξ)−Γ(1−ξ)²)/ξ²` with the
  `ξ = 0` Gumbel limits (`μ+σγ`, `σ²π²/6`); `null` when the mean (`ξ ≥ 1`)
  or variance (`ξ ≥ 1/2`) diverges. The `|ξ| < 1e-8` branch avoids the
  removable singularity.

## Validation

- New tests cover constructor validation, all three regimes' moments and
  support, the `ξ = 0` Gumbel CDF equivalence, CDF/quantile round-trips at
  `p ∈ {1e-6, 0.1, 0.5, 0.9, 1−1e-6}` within `1e-6`, 20k-sample support and
  Monte Carlo moments for `ξ = 0.2`/`−0.25`, the free-function/fill paths,
  and f64x4/f32x8 vector lanes.
- New distcheck gates: a `p`-grid CDF/quantile round-trip (`ξ = 0.3`,
  tolerance `1e-9`) and a 100k-sample mean gate (`2.94..3.04` against the
  analytic `2.987035550983718`).
- `zig build test distcheck --summary all` passes 971/971 tests (native
  950/950).
- Additive API only: no existing sampling stream, benchmark, or behavior
  changed.

## Note

The initial support logic returned 0 above the reversed-Weibull upper bound
and used `−log1p(−p)` for the quantile tail; the round-trip test caught both
(`cdf(quantile(1−1e-6))` returned `0.999999` against the true `1e-6`), and
the final version uses the regime-correct support side and
`E = −log1p(p−1)`.
