# S4-M1574 Tiny-Tail CDF Accuracy Audit

Date: 2026-11-15

## Gap

A systematic `p = 1e-12` / `1 - 1e-12` round-trip audit across 35 continuous
CDF/quantile pairs found four real accuracy gaps:

- `halfNormal`: `cdf(quantile(1e-12))` was 1000x too large (`1.0e-9` vs
  `1e-12`) because `2Φ(t) − 1` cancels and the A&S erf absolute error
  (~1.5e-7) swamps the tiny tail; `halfNormalQuantile` also called `probit`
  at `0.5 + p/2`, where probit's absolute accuracy dominates.
- `TruncatedNormal`: `cdf(quantile(1e-12))` was 1.4e4x too large because
  `(normCdf(z) − cdf_alpha)` subtracts two nearly equal values and the
  quantile called `probit` near the window edge.
- `Kumaraswamy`: the `1 − (1 − x^α)^β` CDF and `1 − (1−p)^{1/β}` quantile
  cancel for tiny tails (`−1.3e-4` relative at `p = 1e-12`).
- `SkewNormal`: the far-left tail below ~`1e-9` is not resolved (see the
  documented limit below).

## Change

- Added `erfTaylor` (erf Taylor series, ~1e-16 for `|t| < 0.5`).
- `halfNormalCdf` now uses `erf(x/(σ√2))` with `erfTaylor` for
  `x/(σ√2) < 0.5` and the A&S form above; `halfNormalQuantile` inverts the
  erf series `σ√(π/2)·p·(1 + πp²/12)` for `p < 1e-3`.
- `TruncatedNormal.cdf` uses the local Hermite series
  `φ(α)·Σ (−1)^{k−1} He_{k−1}(α) δ^k/k!` for `|z − α| < 0.125` (verified to
  ~1e-15 against the exact Φ difference); `quantile` uses
  `δ = mass/φ(edge)` for edge masses below `1e-6`.
- `Kumaraswamy` CDF/quantile use `−expm1(β·log1p(−x^α))` and
  `−expm1(log1p(−p)/β)`.
- `docs/core-guide.md` records the forms and the remaining limits.

## Validation

- Audit after the fixes: `halfNormal`, `TruncatedNormal`, and `Kumaraswamy`
  are no longer flagged; `halfNormalCdf(1e-12) = 7.978845608e-13`
  (`√(2/π)·1e-12`), `truncatedNormal` round-trips to `1.3e-5` relative at
  `p = 1e-12` and `1e-9` at `p = 1e-9`, `Kumaraswamy` to better than `1e-9`.
- New focused tests pin the three fixes; `zig build test --summary all`
  passes 958/958 (native `alea-tests` 939/939) and `distcheck` passes.
- No sampling stream changes: the half-normal, truncated-normal, and
  Kumaraswamy samplers do not call these CDF/quantile helpers.

## Remaining documented limits

- `SkewNormal` far-left tail: `Φ(x) − 2T(x, λ)` cancels both ~`1e-9` terms;
  the true `F(-6) ≈ 8.5e-19` is below the cancellation floor, so quantiles
  below ~`1e-9` are not meaningful.
- Heavy-tailed families (`StudentT`, `Cauchy`, `Weibull`, `Pareto`,
  `Rayleigh`, `Rice`, `GPD`, `SICS`, `InverseGamma`) at `p = 1e-12`:
  round-trip relative error is about `2.2e-5`, i.e. an absolute error of
  `2.2e-17` from the f64 CDF representation near zero, not a formula bug.
