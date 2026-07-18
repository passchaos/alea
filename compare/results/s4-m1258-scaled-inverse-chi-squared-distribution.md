# S4-M1258: Scaled Inverse Chi-Squared Distribution

## Milestone

S4-M1258 — Scaled Inverse Chi-Squared distribution: add a two-parameter
continuous distribution on (0, ∞) serving as the Gelman BDA / BUGS / Stan
parameterization of the conjugate prior for a normal variance. If
X ~ ScaledInvChiSq(ν, τ²) with degrees of freedom ν > 0 and squared scale
τ² > 0, then

    X ~ InverseGamma(α = ν/2, β = ντ²/2)

using alea's existing shape-scale parameterization for InverseGamma (where
Gamma(k, θ) has mean kθ and InverseGamma(α, β) has PDF
β^α/Γ(α) · x^{−(α+1)} · exp(−β/x)). The PDF is

    f(x; ν, τ²) = (ντ²/2)^{ν/2} / Γ(ν/2) · x^{−(ν/2+1)} · exp(−ντ²/(2x)).

Scaled-inverse-χ² is the standard form used in Bayesian statistics for
variance priors:

- Bayesian ANOVA and hierarchical models (Gelman's BDA uses it pervasively).
- BUGS / JAGS / Stan / PyMC parameterizations use (ν, τ²) rather than the
  (α, β) inverse-Gamma shape/scale form.
- Meta-analysis random-effects variance priors.
- Gaussian process noise / kernel amplitude priors.
- Normal-inverse-gamma conjugate priors for (μ, σ²).

Sampling is trivial delegation to the existing InverseGamma sampler via
X = InverseGamma(ν/2, ντ²/2) — no new algorithms or special functions are
required. This is intentionally a thin adapter: providing it as a first-class
distribution spares users the manual parameter mapping (and the off-by-one or
shape/rate vs shape/scale confusion that frequently occurs when hand-applying
it).

## Gap

Local Rust `rand_distr` provides neither Scaled Inverse Chi-Squared nor a
dedicated prior-distribution module. Alea prior to this milestone had
InverseGamma but not the BUGS/Gelman (ν, τ²) parameterization as a first-class
type:

1. Bayesian users working from Gelman BDA, BUGS examples, or Stan code would
   need to hand-apply α = ν/2, β = ντ²/2. This is error-prone because of the
   frequent confusion between shape-rate and shape-scale Gamma parameterizations
   in different software.
2. The canonical half-Cauchy and ScaledInvChiSq variance priors (recommended
   in Gelman 2006 as a weakly-informative alternative to inverse-Gamma)
   become directly accessible.
3. Accessor methods (df/scale/scaleSquared) and moments named in the
   BDA/Stan vocabulary are more readable than hand-computed InverseGamma
   accessors.

## Implementation

### ScaledInverseChiSquaredError

`ScaledInverseChiSquaredError` aliases the generic `Error` set
(`error.InvalidParameter`), consistent with other two-parameter continuous
distributions.

### ScaledInverseChiSquared(T) struct

`ScaledInverseChiSquared(T)` follows the canonical continuous-distribution
struct pattern:

- `comptime requireFloat(T);`
- `init(df, scale_squared)` — validates ν > 0, τ² > 0, both finite.
- `new(df, scale_squared)` — panics in debug on invalid parameters.
- Accessors: `degreesOfFreedomValue()`/`dfValue()`, `scaleSquaredValue()`
  (returns τ²), `scaleValue()` (returns τ = √τ²), `expectedValue()`,
  `varianceValue()`, `modeValue()`, `minValue()`, `maxValue()`.
- Samplers: `sample(rng)`, `sampleFrom(source)`, `fill(rng, dest)`,
  `fillFrom(source, dest)`.

### Parameterization mapping

- α-shape for InverseGamma: `invGammaShape()` returns ν/2.
- β-scale for InverseGamma: `invGammaScale()` returns ντ²/2.

Both are used internally to delegate to `inverseGammaPointFrom(source, T, α, β)`.

### Algorithm

Sampling is a direct delegation:

1. Compute α = ν/2, β = ντ²/2.
2. Return `inverseGammaPointFrom(source, T, α, β)`, which draws
   Y ~ Gamma(α, 1/β) via the existing Gamma Marsaglia-Tsang / Ahrens-Dieter
   path and returns X = 1/Y.

There are no new loops, rejection, or special functions.

### Statistical accessors

Moments follow directly from the InverseGamma identities with α=ν/2, β=ντ²/2:

- **`expectedValue()`**: ντ²/(ν−2) for ν > 2; null (∞) for ν ≤ 2.
- **`varianceValue()`**: 2ν²τ⁴/((ν−2)²(ν−4)) for ν > 4; null for ν ≤ 4.
- **`modeValue()`**: ντ²/(ν+2) for all ν > 0 (always exists).
- **`minValue()`**: 0; **`maxValue()`**: null (∞).

The null return for undefined moments matches alea's heavy-tail convention.

### Free-function family

Following the standard alea scalar distribution pattern:

- Scalar sample: `scaledInverseChiSquared`, `scaledInverseChiSquaredFrom`,
  `scaledInverseChiSquaredChecked`, `scaledInverseChiSquaredCheckedFrom`.
- Bulk fill: `fillScaledInverseChiSquared`, `fillScaledInverseChiSquaredFrom`,
  `fillScaledInverseChiSquaredChecked`, `fillScaledInverseChiSquaredCheckedFrom`.

## Tests

Six new tests in `src/distributions.zig`:

1. **Constructor validation** — rejects ν ≤ 0, τ² ≤ 0, NaN, Inf; accepts
   valid (5,1) and (3,4).
2. **Analytic moments** — ν=5, τ²=1: mean=5/3, var=50/9, mode=5/7; ν=3,
   τ²=4: mean=12, variance infinite (null); ν=2: mean infinite (null).
3. **Accessor correctness** — dfValue/scaleSquaredValue/scaleValue return
   the expected values.
4. **Positivity/finiteness** — 200 samples at (5,2) are all > 0 and finite.
5. **Monte Carlo mean** — 5000 samples at (10,1): sample mean ≈ 1.25 within
   sampling tolerance.
6. **Free functions and fill** — `fillScaledInverseChiSquared` produces
   positive values; `scaledInverseChiSquaredChecked` rejects ν=0; f32
   support with 64 positive finite samples.

All 702 tests pass.

## Deviations from Rust `rand_distr`

- Rust `rand_distr` does not provide Scaled Inverse Chi-Squared. Alea
  extends beyond Rust parity here.
- The constructor takes τ² (squared scale) as the second argument, matching
  Gelman BDA and BUGS/Stan conventions. `scaleValue()` returns τ for
  convenience, and `scaleSquaredValue()` returns the stored τ². This avoids
  a square root in the common case where users pass τ² directly (e.g.,
  `ScaledInvChiSq(ν, s²)` for a prior with scale s).
- Infinite-moment cases (ν ≤ 2 mean, ν ≤ 4 variance) return null rather
  than NaN, consistent with alea's heavy-tail convention.
- Vector/SIMD variants are deferred; scalar and bulk fill are provided.

## Verification

- `zig build test` passes — all 702 tests green.
- `zig build apicheck` passes.
- `zig build roadmapcheck` requires evidence file and closure row.
- `zig build validate` passes all gates.

## Next bar

Noncentral chi/chi-squared, Hoyt (Nakagami-q) fading, Bingham/Matrix-vMF/Kent
directional distributions, vector/SIMD sampling for recent distributions,
copula methods, SIMD spherical bulk paths, weighted/alias advances, string
generation, longer validation runs, broader platform evidence, or newly
discovered core gaps.

## References

- Gelman, A. et al. (2013). *Bayesian Data Analysis* (3rd ed.). CRC Press.
  (Chapter 2: Scaled-inverse-χ² as conjugate prior; Appendix A on
  distributions.)
- Gelman, A. (2006). Prior distributions for variance parameters in
  hierarchical models. *Bayesian Analysis*, 1(3), 515–533.
- Lunn, D. et al. (2012). *The BUGS Book*. CRC Press. (Scaled-inverse-χ²
  parameterization in BUGS.)
- Stan Development Team. *Stan Functions Reference*. (Scaled-inv-chi-square
  distribution; parameterization.)
- Wikipedia contributors. "Scaled inverse chi-squared distribution." In
  *Wikipedia*. (PDF, moments, relationship to inverse-Gamma.)
- Rust `rand_distr` 0.6.0 public surface manifest:
  `compare/results/s4-m294-rand-distr-public-surface-manifest.md`
- Existing Inverse Gamma: `InverseGamma(T)` / `inverseGammaPointFrom` in
  `src/distributions.zig`.
