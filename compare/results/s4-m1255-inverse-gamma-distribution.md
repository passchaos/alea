# S4-M1255: Inverse Gamma Distribution

## Milestone

S4-M1255 — Inverse Gamma distribution: add a two-parameter continuous
distribution on (0, ∞) with shape α > 0 and scale β > 0. X ~ InverseGamma(α, β)
if and only if 1/X ~ Gamma(α, 1/β) (using the shape-scale parameterization
where Gamma(k, θ) has PDF y^{k−1} e^{−y/θ} / (θ^k Γ(k)) and mean kθ).

The PDF is:

    f(x; α, β) = β^α / Γ(α) · x^{−(α+1)} · exp(−β/x)   for x > 0.

Inverse Gamma is the canonical conjugate prior for the variance (precision
reciprocal) parameter of a normal distribution in Bayesian statistics, and
sees ubiquitous use as a variance prior in:

- Bayesian linear / logistic regression (variance of residuals).
- Gaussian processes (noise variance, kernel amplitude priors).
- Hierarchical models and multilevel regression.
- MCMC samplers (Gibbs steps for normal variance).
- Finance (inverse-volatility priors).

The scaled-inverse-χ²(ν, s²) parameterization used in BUGS/Stan/Gelman's BDA
is exactly InverseGamma(ν/2, ν·s²/2) — a simple parameterization adapter that
users can construct directly from InverseGamma.

Sampling is rejection-free: X = 1 / Gamma(α, 1/β), trivially leveraging the
existing Gamma sampler with no new special functions.

## Gap

Local Rust `rand`/`rand_distr` does not provide an Inverse Gamma distribution.
Alea prior to this milestone had Gamma but not its reciprocal transformation
as a first-class distribution:

1. No Inverse Gamma distribution for Bayesian variance prior workflows.
2. Users implementing MCMC or Bayesian models would need to hand-write
   `1.0 / gamma(rng, α, 1/β)` without access to proper validation, moments,
   and the standard alea distribution API surface.
3. Scaled-inverse-χ² remains a one-line adapter that can be added later;
   shipping InverseGamma unblocks it trivially.
4. Noncentral chi/chi-squared (next major gap) is partially served by
   Poisson-mixture algorithms but needs dedicated implementation.

## Implementation

### InverseGammaError

`InverseGammaError` aliases the generic `Error` set (`error.InvalidParameter`),
consistent with other two-parameter continuous distributions whose validation
is positivity/finiteness.

### InverseGamma(T) struct

`InverseGamma(T)` follows the canonical continuous-distribution struct pattern:

- `comptime requireFloat(T);`
- `init(shape, scale)` — validates α > 0, β > 0, both finite (strictly
  positive; unlike fading-family distributions, zero-parameter degenerate
  cases are not meaningful for IG).
- `new(shape, scale)` — panics in debug on invalid parameters.
- Accessors: `shapeValue()`, `scaleValue()`, `expectedValue()`,
  `varianceValue()`, `modeValue()`, `minValue()`, `maxValue()`.
- Samplers: `sample(rng)`, `sampleFrom(source)`, `fill(rng, dest)`,
  `fillFrom(source, dest)`.

### Parameterization note

alea's Gamma follows the standard shape-scale (k, θ) convention (as opposed
to shape-rate (k, β = 1/θ)): Gamma(k, θ) has mean kθ. Therefore to obtain
X ~ IG(α, β) (where IG(α, β) has PDF β^α/Γ(α) · x^{−(α+1)} · exp(−β/x)),
we draw Y ~ Gamma(α, 1/β) and set X = 1/Y. The verification is:

    f_X(x) = f_Y(1/x) · |d/dx (1/x)|^{−1}
           = (1/x)^{α−1} exp(−(1/x)/(1/β)) / ((1/β)^α Γ(α)) · x²
           = x^{−(α+1)} · β^α · exp(−β/x) / Γ(α)   ✓

### Algorithm

Sampling is rejection-free and O(1):

1. Draw Y ~ Gamma(shape=α, scale=1/β) via `gammaFrom(source, T, α, 1/β)`.
2. Return X = 1/Y.

There are no degenerate fast paths (α,β must be strictly positive). The
Gamma sampler handles small/large shape with its existing Marsaglia-Tsang/
Ahrens-Dieter switching.

### Statistical accessors

Moments follow from standard Inverse Gamma identities:

- **`expectedValue()`**: β/(α−1) for α > 1; returns +∞ for α ≤ 1 (mean
  does not exist in the heavy-tailed regime; the integral diverges).
- **`varianceValue()`**: β²/((α−1)²(α−2)) for α > 2; returns +∞ for
  α ≤ 2 (variance diverges for α ≤ 2).
- **`modeValue()`**: β/(α+1) for all α > 0 (always exists).
- **`minValue()`**: 0; **`maxValue()`**: null (support is (0, ∞)).

The +∞ return for undefined moments is intentional: it mirrors the
mathematical behavior (no finite mean), and downstream code that computes
summary statistics on samples will naturally see very large sample values
when α is close to the boundary, matching the heavy-tailed truth. This is
consistent with how alea handles Levy α-stable tails elsewhere.

### Free-function family

Following the standard alea scalar distribution pattern:

- Scalar sample: `inverseGamma`, `inverseGammaFrom`, `inverseGammaChecked`,
  `inverseGammaCheckedFrom`.
- Bulk fill: `fillInverseGamma`, `fillInverseGammaFrom`,
  `fillInverseGammaChecked`, `fillInverseGammaCheckedFrom`.

`*From` variants accept a custom source; `*Checked` variants return an
`InverseGammaError` union; non-Checked variants use `.new()` (panic in debug
on invalid parameters).

## Tests

Eight new tests in `src/distributions.zig`:

1. **Constructor validation** — rejects α=0, α=−1, β=0, β=−1, NaN, Inf;
   accepts valid IG(3,2) with correct accessor values.
2. **Analytic moments** — IG(3,2): mean=1, variance=1, mode=0.5 all to
   1e-12; IG(5,4): mean=1, variance=1/3, mode=2/3 all to 1e-12.
3. **Infinite moments for small shape** — α=0.5 gives infinite mean and
   variance; α=1.5 gives finite mean but infinite variance (std.math.isInf
   checks).
4. **Positivity/finiteness** — 500 samples at (α=3, β=2) are all > 0 and
   finite.
5. **Reciprocal-Gamma identity** — for IG(α=3, β=2), reciprocals of samples
   should have mean α/β = 1.5 (since 1/X ~ Gamma(α, 1/β), mean α·(1/β)
   wait: Gamma(k,θ) mean kθ = α·(1/β) = α/β = 3/2 = 1.5); 2000-sample
   Monte Carlo gives E[1/X] ≈ 1.5 within 0.1.
6. **Monte Carlo mean/variance** — 5000 samples from IG(5,4): sample mean
   ≈ 1 within 0.05, sample variance ≈ 1/3 within 0.08.
7. **Free functions and fill** — `fillInverseGammaChecked` produces positive
   values; `inverseGammaChecked` rejects α=0; `inverseGamma` returns a
   positive finite value.
8. **f32 support** — f32 variant at (α=3, β=2) produces 64 positive finite
   samples with mean = 1 within 1e-6.

All 676 tests pass (668 pre-existing + 8 new).

## Deviations from Rust `rand_distr`

- Rust `rand_distr` does not provide Inverse Gamma. Alea extends beyond
  parity here (continuing the pattern of Truncated Normal, Von Mises,
  Wrapped Cauchy, Von Mises-Fisher, Watson, Rice, and Nakagami-m).
- The infinite-moment return convention uses +∞ rather than NaN or a panic.
  This matches the mathematical divergence and is consistent with other
  heavy-tailed distributions in alea (Cauchy, Levy).
- We use the shape-scale parameterization (β as scale, not rate), matching
  Gelman's BDA and the majority of Bayesian statistics references. The
  shape-rate form (with PDF β^α/Γ(α) · x^{−(α+1)} · exp(−β/x) — identical
  PDF, just different parameter naming) is not separately exposed; users
  who want the rate form can pass scale = 1/rate.
- Scaled-inverse-χ²(ν, s²) is not a separate type; it is trivially
  constructible as InverseGamma(ν/2, ν·s²/2). A convenience wrapper can be
  added in a follow-up if needed.
- Vector/SIMD variants (VectorInverseGamma) are deferred; the scalar and
  bulk fill APIs provide the full scalar/fill surface consistent with the
  recent Rice/Nakagami pattern.

## Verification

- `zig build test` passes — all 676 tests green.
- `zig build apicheck` passes — all 24 new public symbols documented in
  `docs/api-reference.md`.
- `zig build roadmapcheck` requires `compare/results/s4-m1255-inverse-gamma-distribution.md`
  and a `| S4-M1255 | Inverse Gamma distribution` closure row in
  `core-rand-coverage.md`.
- `zig build validate` passes all gates (apicheck, readmecheck, examplecheck,
  toolingcheck, distcheck, statcheck, roadmapcheck, practrand self-test,
  profilecheck).

## Next bar

Noncentral chi/chi-squared, Exponentially Modified Gaussian (ExGaussian),
Generalized Pareto, Scaled Inverse Chi-Squared (parameterization adapter),
Hoyt (Nakagami-q) fading, additional directional/multivariate distributions
(Bingham, Matrix von Mises-Fisher, Kent), Rice/Nakagami/InverseGamma
vector/SIMD sampling, copula methods, SIMD spherical bulk paths, weighted/
alias advances, string generation expansion, longer validation runs, broader
platform evidence, or newly discovered core gaps.

## References

- Gelman, A. et al. (2013). *Bayesian Data Analysis* (3rd ed.). CRC Press.
  (Inverse Gamma as conjugate prior for normal variance; scaled-inverse-χ²
  parameterization in Chapter 2.)
- Robert, C. P. & Casella, G. (2004). *Monte Carlo Statistical Methods*
  (2nd ed.). Springer. (Chapter 2: conjugate priors.)
- Wikipedia contributors. "Inverse-gamma distribution." In *Wikipedia*.
  (PDF, moments, parameterization, Gamma reciprocal identity.)
- Rust `rand_distr` 0.5.1/0.6 public surface manifest:
  `compare/results/s4-m294-rand-distr-public-surface-manifest.md`
- Existing Gamma distribution: `Gamma(T)` / `gammaFrom` in `src/distributions.zig`.
- Preceding fading-family milestones: S4-M1253 (Rice), S4-M1254 (Nakagami-m).