# S4-M1257: Generalized Pareto Distribution (GPD)

## Milestone

S4-M1257 — Generalized Pareto Distribution: add a three-parameter continuous
distribution on a location-dependent support, unifying three tail regimes in
extreme value theory. The GPD with location μ ∈ ℝ, scale σ > 0, and shape ξ
(tail index) has CDF

    F(x; μ, σ, ξ) = 1 − (1 + ξ(x−μ)/σ)^{−1/ξ}    for ξ ≠ 0,
    F(x; μ, σ, 0) = 1 − exp(−(x−μ)/σ)            for ξ = 0,

and PDF

    f(x; μ, σ, ξ) = (1/σ)(1 + ξ(x−μ)/σ)^{−1/ξ−1}  for ξ ≠ 0,
    f(x; μ, σ, 0) = (1/σ)exp(−(x−μ)/σ)            for ξ = 0.

Support is:
- x ≥ μ when ξ ≥ 0 (heavy/regular tail, upper end ∞),
- μ ≤ x ≤ μ − σ/ξ when ξ < 0 (bounded short tail, finite upper endpoint).

GPD is the canonical peaks-over-threshold (POT) model in extreme value theory:
exceedances over a high threshold converge in distribution to GPD (Pickands–
Balkema–de Haan theorem). Application domains include:

- Hydrology: flood frequencies, rainfall extremes, sea-level surges.
- Finance: value-at-risk (VaR), expected shortfall, tail-risk modeling.
- Insurance: large-loss modeling, reinsurance pricing.
- Environmental science: extreme wind speeds, temperature anomalies.
- Reliability: tail-life modeling beyond a warranty threshold.
- Telecommunications: heavy-tailed traffic and queue lengths.

The three regimes are:
1. ξ = 0 (Gumbel basin): reduces identically to Exponential(μ, σ).
2. ξ > 0 (Fréchet / polynomial tail): Pareto-like; mean diverges at ξ ≥ 1,
   variance at ξ ≥ 1/2. Classical Pareto Type I (with scale x_m and shape α)
   is a reparameterization: GPD(μ=x_m, σ=x_m/α, ξ=1/α).
3. ξ < 0 (Weibull / bounded tail): finite upper endpoint; ξ = −1 gives
   Uniform(μ, μ+σ) as a special case.

Sampling is inverse-CDF and rejection-free:

    X = μ + σ·(U^{−ξ} − 1)/ξ   for ξ ≠ 0,
    X = μ − σ·ln U              for ξ = 0,

where U ~ Uniform(0,1]. This is a single exponentiation (or log) plus
arithmetic — no rejection loops.

## Gap

Local Rust `rand_distr` provides a classical Pareto (Type I) distribution
(equivalent to GPD at a single ξ = 1/α point) but does not provide the full
three-regime GPD with arbitrary shape ξ, location μ, or bounded-support
negative-shape behavior. Alea prior to this milestone had the two-parameter
Pareto (Type I) distribution but not the generalized form:

1. No GPD for extreme-value / POT tail-modeling workflows (VaR, expected
   shortfall, flood-frequency analysis).
2. Users fitting peaks-over-threshold models would need to hand-code the
   inverse CDF, including correct ξ=0 exponential and ξ<0 bounded branches,
   without access to validated moments and parameter-validated API.
3. Heavy-tail cases with infinite mean (ξ ≥ 1) or infinite variance (ξ ≥ 1/2)
   need null returns consistent with alea's Cauchy/Levy/InverseGamma infinite-
   moment convention — hand-rolled code would likely return NaN or panic.
4. Bounded-support GPD (ξ < 0) with finite upper bound was entirely absent;
   the two-parameter Pareto cannot model bounded tails.

## Implementation

### GeneralizedParetoError

`GeneralizedParetoError` aliases the generic `Error` set (`error.InvalidParameter`),
consistent with other continuous distributions whose validation is positivity
and finiteness.

### GeneralizedPareto(T) struct

`GeneralizedPareto(T)` follows the canonical continuous-distribution struct
pattern:

- `comptime requireFloat(T);`
- `init(mu, sigma, xi)` — validates σ ≥ 0, all parameters finite; σ = 0
  accepted as a degenerate point mass at μ; NaN/±Inf rejected.
- `new(mu, sigma, xi)` — panics in debug on invalid parameters.
- Accessors: `locationValue()`/`muValue()`, `scaleValue()`/`sigmaValue()`,
  `shapeValue()`/`xiValue()`/`tailIndexValue()`, `expectedValue()`,
  `varianceValue()`, `medianValue()`, `modeValue()`, `minValue()`, `maxValue()`.
- Samplers: `sample(rng)`, `sampleFrom(source)`, `fill(rng, dest)`,
  `fillFrom(source, dest)`.

### Algorithm

Sampling is inverse-CDF, rejection-free, O(1):

1. Draw U ~ Uniform(0,1] via `Rng.floatOpenFrom(source, T)`.
2. If ξ = 0: return μ − σ·ln U (shifted exponential).
3. Else: return μ + σ·(U^{−ξ} − 1)/ξ; computed as μ + σ·(exp(−ξ·lnU) − 1)/ξ
   for numerical stability at small |ξ|.

The σ = 0 fast path returns μ identically (degenerate point mass). The ξ = 0
and ξ ≠ 0 branches handle all three tail regimes without additional branching.

### Statistical accessors

Moments use standard GPD identities:

- **`expectedValue()`**: μ + σ/(1−ξ) for ξ < 1; null (+∞ mean diverges) for ξ ≥ 1.
- **`varianceValue()`**: σ²/((1−ξ)²(1−2ξ)) for ξ < 1/2; null for ξ ≥ 1/2.
- **`medianValue()`**: μ + σ·ln 2 for ξ = 0; μ + σ·(2^ξ − 1)/ξ for ξ ≠ 0.
- **`modeValue()`**: μ for all ξ (PDF is monotone decreasing from a finite
  maximum at the threshold in every GPD regime).
- **`minValue()`**: μ; **`maxValue()`**: μ − σ/ξ for ξ < 0 (bounded),
  else null (∞).

The null return for undefined moments matches alea's existing heavy-tail
convention (Cauchy, Levy, InverseGamma).

### Free-function family

Following the standard alea scalar distribution pattern:

- Scalar sample: `generalizedPareto`, `generalizedParetoFrom`,
  `generalizedParetoChecked`, `generalizedParetoCheckedFrom`.
- Bulk fill: `fillGeneralizedPareto`, `fillGeneralizedParetoFrom`,
  `fillGeneralizedParetoChecked`, `fillGeneralizedParetoCheckedFrom`.

`*From` variants accept a custom source; `*Checked` variants return an
`GeneralizedParetoError` union; non-Checked variants use `.new()` (panic in
debug on invalid parameters).

## Tests

Eight new tests in `src/distributions.zig`:

1. **Constructor validation** — rejects σ < 0, NaN, Inf parameters; accepts
   valid ξ=0, ξ=0.5, ξ=−0.25, and degenerate σ=0.
2. **Analytic moments across regimes** — ξ=0 exponential (mean=1, var=1,
   median=ln2, mode=0); ξ=0.2 heavy with finite variance (mean=1.25,
   var≈2.604); ξ=0.6 finite mean / infinite variance (mean=2.5, null
   variance); ξ=1.5 infinite mean (null); ξ=−0.25 bounded with upper
   endpoint 4 (mean=0.8, max=4).
3. **Support containment** — 200 samples for each of ξ=0 (all ≥ 0), ξ=−0.25
   (all in [0,4]), and σ=0 degenerate (all = 5).
4. **Monte Carlo for ξ=0 (exponential)** — 5000 samples with mean ≈ 1
   within 0.06, variance ≈ 1 within 0.1.
5. **Free functions and fill** — `fillGeneralizedPareto` produces values ≥ 0;
   `generalizedParetoChecked` rejects σ=−1; `generalizedPareto` returns a
   non-negative value.
6. **f32 support** — f32 variant at (μ=0, σ=1, ξ=0) produces 64 finite
   non-negative samples with mean ≈ 1.

All 702 tests pass (684 pre-existing + 18 new across three distributions).

## Deviations from Rust `rand_distr`

- Rust `rand_distr` does not provide GPD. It provides a two-parameter
  Pareto (Type I) but not the three-regime generalized form. Alea extends
  beyond Rust parity here.
- The ξ < 0 bounded-support branch is provided, correctly computing a finite
  upper endpoint. This is a feature absent from both Rust `rand_distr` and
  many simpler GPD implementations.
- Infinite-moment cases (ξ ≥ 1 mean, ξ ≥ 1/2 variance) return null rather
  than NaN, consistent with alea's existing heavy-tail convention (Cauchy,
  Levy, InverseGamma).
- σ = 0 is accepted as a degenerate point mass at μ, consistent with other
  zero-scale conventions in alea (e.g., Rice σ=0, Pareto scale=0).
- Vector/SIMD variants (VectorGeneralizedPareto) are deferred; the scalar and
  bulk fill APIs provide the full scalar/fill surface.

## Verification

- `zig build test` passes — all 702 tests green.
- `zig build apicheck` passes — all new public symbols documented in
  `docs/api-reference.md`.
- `zig build roadmapcheck` requires evidence file and closure row.
- `zig build validate` passes all gates.

## Next bar

Noncentral chi/chi-squared, Scaled Inverse Chi-Squared (parameterization
adapter), Hoyt (Nakagami-q) fading, Bingham/Matrix-vMF/Kent directional
distributions, vector/SIMD sampling for recent distributions, copula methods,
SIMD spherical bulk paths, weighted/alias advances, string generation, longer
validation runs, broader platform evidence, or newly discovered core gaps.

## References

- Pickands, J. (1975). Statistical inference using extreme order statistics.
  *Annals of Statistics*, 3(1), 119–131. (POT theorem.)
- Balkema, A. A. & de Haan, L. (1974). Residual life time at great age.
  *Annals of Probability*, 2(5), 792–804.
- Embrechts, P., Klüppelberg, C., & Mikosch, T. (1997). *Modelling Extremal
  Events for Insurance and Finance*. Springer. (Chapter 3: GPD.)
- Coles, S. (2001). *An Introduction to Statistical Modeling of Extreme
  Values*. Springer. (Chapter 4: threshold models and GPD.)
- McNeil, A. J., Frey, R., & Embrechts, P. (2015). *Quantitative Risk
  Management*. Princeton. (Chapter 7: EVT for VaR/expected shortfall.)
- Wikipedia contributors. "Generalized Pareto distribution." In *Wikipedia*.
  (PDF, CDF, moments, regimes, parameterizations.)
- Rust `rand_distr` 0.6.0 public surface manifest:
  `compare/results/s4-m294-rand-distr-public-surface-manifest.md`
- Existing Pareto (Type I): `Pareto(T)` / `paretoFrom` in `src/distributions.zig`.
