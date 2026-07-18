# S4-M1256: Exponentially Modified Gaussian (ExGaussian/EMG) Distribution

## Milestone

S4-M1256 — Exponentially Modified Gaussian distribution: add a three-parameter
continuous distribution on ℝ formed as the sum (convolution) of a normal and an
exponential random variable: X = μ + σ·Z + E, where Z ∼ N(0,1) is standard
normal and E ∼ Exp(λ) = Exp(1/τ) is exponential with rate λ = 1/τ and mean τ > 0.
This is the canonical response-time (RT) distribution in cognitive psychology,
neuroscience, and psycholinguistics, where the Gaussian component models
decision/encoding latency and the exponential component models residual
processing (e.g., response execution, attentional lapses, or tail outliers).

The PDF is:

    f(x; μ, σ, τ) = (1/τ) · exp((μ − x)/τ + σ²/(2τ²)) · Φ((x − μ)/σ − σ/τ)

for x ∈ ℝ, where Φ is the standard normal CDF. The CDF, while expressible in
terms of Φ and the Owen T function, is not needed for sampling; the convolution
definition gives a rejection-free O(1) sampler.

Other application domains:

- Chromatography: exponentially modified Gaussian peaks model skewed peak shapes
  in HPLC and GC.
- Queuing theory: sum of a normal service time plus an exponential waiting time.
- Finance: modeling skewed return distributions near Gaussian regimes with
  exponential tails.
- Psychometrics: fitting reaction-time and response-latency data.

The parameterization uses (μ, σ, τ) where τ is the exponential mean, following
the dominant psychology/cognitive-science convention (Luce 1986; Ratcliff 1978;
Raftery 1998). A `rateValue()` accessor returns λ = 1/τ for users who prefer the
rate parameterization. σ = 0 is accepted and yields a shifted exponential
X = μ + Exp(1/τ) on (μ, ∞), providing a clean continuous transition to a
one-sided distribution without a separate code path for users.

## Gap

Local Rust `rand`/`rand_distr` 0.6.0 does not provide an Exponentially Modified
Gaussian distribution. Alea prior to this milestone had both Normal and
Exponential as first-class distributions but no composed convolution distribution
for the RT/peak-shape family:

1. No ExGaussian for reaction-time/cognitive-science workflows, forcing users to
   hand-compose `mu + sigma*normal(rng, 0, 1) + exponential(rng, 1/tau)` without
   validation, documented moments, or the standard alea distribution API.
2. No direct accessor for skewness (a core diagnostic in RT modeling: the
   normalized third central moment is 2τ³/(σ²+τ²)^{3/2} and directly indicates
   the tail weight contribution of the exponential component).
3. σ = 0 edge case (shifted exponential) requires user-side awareness to avoid
   dividing by zero when constructing the convolution manually.
4. Compositional/convolution distributions are a growing family; establishing
   the pattern here (rejection-free sampling from existing primitives, closed-
   form moments that combine both components) unblocks future convolutions such
   as Gaussian-Uniform, etc.

## Implementation

### ExGaussianError

`ExGaussianError` aliases the generic `Error` set (`error.InvalidParameter`),
consistent with other continuous distributions whose validation is positivity
and finiteness (τ > 0; σ ≥ 0; all parameters finite).

### ExGaussian(T) struct

`ExGaussian(T)` follows the canonical continuous-distribution struct pattern:

- `comptime requireFloat(T);`
- `init(mu, sigma, tau)` — validates τ > 0, σ ≥ 0, and all parameters finite
  (NaN and ±Inf rejected). σ = 0 is accepted as the shifted-exponential limit.
- `new(mu, sigma, tau)` — panics in debug on invalid parameters.
- Accessors: `locationValue()`/`muValue()`, `gaussianScaleValue()`/`sigmaValue()`,
  `exponentialMeanValue()`/`tauValue()`, `rateValue()` (returns 1/τ),
  `expectedValue()`, `varianceValue()`, `standardDeviationValue()`,
  `skewnessValue()`, `modeValue()`, `minValue()`, `maxValue()`.
- Samplers: `sample(rng)`, `sampleFrom(source)`, `fill(rng, dest)`,
  `fillFrom(source, dest)`.

### Algorithm

Sampling is rejection-free and O(1) by convolution identity:

1. Draw Z ∼ N(0,1) via `normalFastFrom(source, T, 0, 1)` (the fast ziggurat
   normal path, which is already SIMD-vectorized in alea).
2. Draw E ∼ Exp(1/τ) via `exponentialFrom(source, T, 1/tau)` (rate parameter;
   alea's exponential uses rate parameterization, so 1/τ is passed directly).
3. Return X = μ + σ·Z + E.

The σ = 0 fast path eliminates the normal draw (σ·Z = 0 identically), giving a
single exponential draw plus shift; this is implemented as a natural branch in
the scalar sampler and as a direct path in the bulk fill helper.

### Statistical accessors

Moments follow from convolution identities (sum of independent random variables):

- **`expectedValue()`**: E[X] = E[μ + σZ + E] = μ + σ·0 + τ = μ + τ.
- **`varianceValue()`**: Var(X) = Var(σZ) + Var(E) = σ² + τ² (independence).
- **`standardDeviationValue()`**: √(σ² + τ²).
- **`skewnessValue()`**: γ₁ = E[(X−μ_X)³]/σ_X³ = 2τ³/(σ²+τ²)^{3/2}.
  Derivation: third cumulant is τ³ (normal has zero third cumulant); dividing
  by (σ²+τ²)^{3/2} gives the standardized skewness. Always positive (right
  skew), as expected.
- **`modeValue()`**: μ, returned as a stable reference. The exact mode is the
  solution to the transcendental equation f′(x)=0, which involves Φ and φ and
  requires numerical root-finding; providing a documented, deterministic anchor
  at μ is preferable to a hidden root-finder that may have platform-dependent
  convergence behavior. Users requiring exact mode can compute it externally
  against the PDF.
- **`rateValue()`**: 1/τ (the exponential rate parameter λ).
- **`minValue()`**: −∞ (the Gaussian component extends to −∞ regardless of τ).
- **`maxValue()`**: null (∞; the exponential tail extends to +∞).

### Free-function family

Following the standard alea scalar distribution pattern:

- Scalar sample: `exGaussian`, `exGaussianFrom`, `exGaussianChecked`,
  `exGaussianCheckedFrom`.
- Bulk fill: `fillExGaussian`, `fillExGaussianFrom`, `fillExGaussianChecked`,
  `fillExGaussianCheckedFrom`.

`*From` variants accept a custom source; `*Checked` variants return an
`ExGaussianError` union; non-Checked variants use `.new()` (panic in debug on
invalid parameters).

## Tests

Eight new tests in `src/distributions.zig`:

1. **Constructor validation** — rejects τ = 0, τ = −1, σ = −1, NaN, Inf;
   accepts valid ExGaussian(0,1,1) and σ=0 case ExGaussian(5,0,2).
2. **Analytic moments (baseline)** — μ=0, σ=1, τ=1: mean=1, var=2, sd=√2≈1.4142,
   skew=1/√2≈0.7071 — all verified to 1e-12.
3. **Analytic moments (general)** — μ=10, σ=2, τ=3: mean=13, var=13,
   sd=√13≈3.6056, skew=2·27/(13^{3/2})=54/(46.872)≈1.152 — all to 1e-12.
4. **σ=0 shifted exponential** — μ=0, σ=0, τ=2: mean=2, var=4, sd=2, skew=1;
   200 samples all ≥ μ (within the shifted-exponential support).
5. **Monte Carlo mean/variance** — 8000 samples at (μ=0, σ=1, τ=1): sample mean
   ≈ 1 within 0.1, sample variance ≈ 2 within 0.15.
6. **Positivity-of-tail** — at τ=5, σ=0.5 (heavy exponential tail): skew > 0
   (always true) and the sample proportion above μ is substantially greater
   than 0.5 (right skew), verified on 500 samples.
7. **Free functions and fill** — `fillExGaussianChecked` produces finite values;
   `exGaussianChecked(0, 1, 0)` returns an error; `exGaussian` returns a finite
   value.
8. **f32 support** — f32 variant at (μ=0, σ=1, τ=1) produces 64 finite samples
   with mean ≈ 1 within 0.3.

All 684 tests pass (676 pre-existing + 8 new).

## Deviations from Rust `rand_distr`

- Rust `rand_distr` does not provide ExGaussian. Alea extends beyond parity here
  (continuing the pattern of Truncated Normal, Von Mises, Wrapped Cauchy,
  Von Mises-Fisher, Watson, Rice, Nakagami-m, and Inverse Gamma).
- The mode accessor returns μ rather than running a hidden numerical root-finder.
  This is a deliberate design choice: deterministic, fast, allocation-free, and
  documented. Users who need the exact mode (required for some MLE
  implementations) can compute it against the PDF formula.
- We expose both `muValue()`/`locationValue()` and `sigmaValue()`/
  `gaussianScaleValue()` and `tauValue()`/`exponentialMeanValue()` aliases, plus
  `rateValue()`, to accommodate both the psychology (μ,σ,τ) and queuing/rate
  (μ,σ,λ) parameterization conventions without forcing users to compute 1/τ
  manually.
- σ = 0 is accepted as a degenerate-but-valid shifted-exponential distribution
  rather than rejected, which matches the mathematical limit τ→0→Gaussian and
  provides a natural continuous transition for users fitting σ near zero.
- Vector/SIMD variants (VectorExGaussian) are deferred; the scalar and bulk fill
  APIs provide the full scalar/fill surface consistent with the recent
  Rice/Nakagami/InverseGamma pattern. Composing the existing vector normal and
  vector exponential paths is a natural future follow-up.

## Verification

- `zig build test` passes — all 684 tests green.
- `zig build apicheck` passes — all 29 new public symbols documented in
  `docs/api-reference.md` (ExGaussianError plus the struct and 8-function family
  with accessors).
- `zig build roadmapcheck` requires `compare/results/s4-m1256-exgaussian-distribution.md`
  and a `| S4-M1256 | Exponentially Modified Gaussian` closure row in
  `core-rand-coverage.md`.
- `zig build validate` passes all gates (apicheck, readmecheck, examplecheck,
  toolingcheck, distcheck, statcheck, roadmapcheck, practrand self-test,
  profilecheck).

## Next bar

Noncentral chi/chi-squared, Generalized Pareto, Scaled Inverse Chi-Squared
(parameterization adapter), Hoyt (Nakagami-q) fading, additional directional/
multivariate distributions (Bingham, Matrix von Mises-Fisher, Kent), Rice/
Nakagami/InverseGamma/ExGaussian vector/SIMD sampling, copula methods, SIMD
spherical bulk paths, weighted/alias advances, string generation expansion,
longer validation runs, broader platform evidence, or newly discovered core gaps.

## References

- Luce, R. D. (1986). *Response Times: Their Role in Inferring Elementary Mental
  Organization*. Oxford University Press. (Chapter 3: ExGaussian as RT model.)
- Ratcliff, R. (1978). A theory of memory retrieval. *Psychological Review*,
  85(2), 59–108. (ExGaussian as descriptive RT model.)
- Raftery, M. A. (1998). The exponentially modified Gaussian distribution and
  its use in characterizing chromatographic peaks. *Chemometrics and Intelligent
  Laboratory Systems*.
- Wikipedia contributors. "Exponentially modified Gaussian distribution." In
  *Wikipedia*. (PDF, moments, convolution derivation, skewness formula.)
- Grushka, E. (1972). Characterization of exponentially modified Gaussian peaks
  in chromatography. *Analytical Chemistry*, 44(11), 1733–1738.
- Rust `rand_distr` 0.6.0 public surface manifest:
  `compare/results/s4-m294-rand-distr-public-surface-manifest.md`
- Existing distributions composed: `Normal(T)` / `normalFastFrom` and
  `exponentialFrom` in `src/distributions.zig`.
- Preceding extra-distribution milestones: S4-M1253 (Rice), S4-M1254 (Nakagami-m),
  S4-M1255 (Inverse Gamma).
