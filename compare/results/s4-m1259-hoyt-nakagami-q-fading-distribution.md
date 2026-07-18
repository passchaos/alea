# S4-M1259: Hoyt (Nakagami-q) Fading Distribution

## Milestone

S4-M1259 — Hoyt (Nakagami-q) fading distribution: add a two-parameter
continuous distribution on [0, ∞) for multipath fading envelope modeling.
Hoyt (Nakagami-q) is the canonical model for fading channels where scattered
multipath components have unequal power (in contrast to Rayleigh, which assumes
equal-power isotropic scatter, and Rician/Rice, which assumes a dominant
specular line-of-sight component plus equal-power scatter). The Hoyt PDF is

    f(x; q, Ω) = (1+q²)/(qΩ) · x · exp(−(1+q²)x²/(2Ω)) ·
                 I₀((1−q²)x²/(2Ω))     (in Bessel form)

where q ∈ (0, 1] is the fading parameter (often denoted as *b* in some
texts), Ω = E[X²] > 0 is the mean-squared envelope (spread/second moment),
and I₀ is the modified Bessel function of the first kind of order 0.
Equivalently, the Hoyt distribution models the magnitude:

    X = σ · √(Z₁² + (q·Z₂)²),    σ = √(Ω/(1+q²)),

where Z₁, Z₂ ~ N(0, 1) are i.i.d. standard normals. This two-Gaussian product
form is the defining construction and yields an immediate rejection-free
sampler (two normal draws + one square root + multiplies).

Parameter limits:

- q = 1 → exactly Rayleigh(σ) with σ = √(Ω/2), since X = σ·√(Z₁²+Z₂²).
- q → 0 → the distribution collapses to a one-sided (half) Gaussian
  concentrated near 0 (severe fading with no strong scattered component).
- q < 0 and q > 1 are invalid.

Other application domains:

- Wireless communications: fading channels with unequal in-phase/quadrature
  scatter power (satellite, urban microcellular, ionospheric).
- Radar: target cross-section fluctuations (Swerling III/IV models are
  related).
- Optics: beam propagation in turbulent media.
- Finance: modeling volatility envelope distributions.

This milestone also adds a standalone `besselI1(z)` modified Bessel
function (order 1), complementing the existing `besselI0(z)` introduced for
Rice, using Abramowitz & Stegun polynomial/asymptotic approximations
accurate to ~1e-7 across z ≥ 0.

## Gap

Local Rust `rand_distr` does not provide Hoyt/Nakagami-q. It provides
Rayleigh (q=1 limit) and Rice/Rician (line-of-sight plus equal scatter)
but not the unequal-power scattered-component family. Alea prior to this
milestone had Rice and Nakagami-m (which approximates Rice for m > 1)
but not the complementary Hoyt form:

1. No Hoyt distribution for unequal-power multipath fading workflows.
2. Users implementing q-parameter fading (common in satellite, HF, and
   ionospheric channels) would need to hand-compose σ·√(Z₁² + (q·Z₂)²)
   without validated moments or proper parameter validation.
3. The Hoyt mean uses a Bessel form (I₀ + I₁) requiring a Bessel-I₁
   implementation that was previously only available through the ratio
   helper `besselI1Ratio` (which returns I₁/I₀). Adding a standalone
   `besselI1(z)` unblocks future Bessel-family distributions (noncentral
   chi, Rician K-factor expansions, etc.).

## Implementation

### Supporting addition: besselI1(z)

`besselI1(z)` implements the modified Bessel function I₁(z) for real z:

- For |z| ≤ 3.75: Abramowitz & Stegun polynomial approximation
  (A&S 9.8.3), using an odd-function form
    I₁(z) = (z/2) · (1 + t·(0.87890594 + t·(0.51498869 + ...)))
  where t = (z/3.75)², accurate to ~1e-7.
- For |z| > 3.75: A&S 9.8.4 asymptotic expansion
    I₁(z) ≈ exp(z)/√(2πz) · correction_polynomial(y), y = 3.75/z.
- Oddness: I₁(−z) = −I₁(z) for z < 0; I₁(0) = 0.

This mirrors the existing `besselI0` in structure and accuracy and reuses
the same `anytype` signature so it works for both f32 and f64.

### HoytError

`HoytError` aliases the generic `Error` set (`error.InvalidParameter`).

### Hoyt(T) struct

`Hoyt(T)` follows the canonical continuous-distribution struct pattern:

- `comptime requireFloat(T);`
- `init(q, omega)` — validates 0 < q ≤ 1, Ω ≥ 0, both finite; Ω = 0 accepted
  as a degenerate point mass at 0.
- `new(q, omega)` — panics in debug on invalid parameters.
- Accessors: `qValue()`/`fadingParameterValue()`, `spreadValue()`/`omegaValue()`,
  `sigmaValue()` (σ = √(Ω/(1+q²))), `expectedValue()`, `varianceValue()`,
  `standardDeviationValue()`, `modeValue()`, `minValue()`, `maxValue()`.
- Samplers: `sample(rng)`, `sampleFrom(source)`, `fill(rng, dest)`,
  `fillFrom(source, dest)`.

### Algorithm

Sampling is rejection-free via the defining Gaussian product form:

1. Compute σ = √(Ω/(1+q²)).
2. Draw Z₁, Z₂ ~ N(0,1) via two calls to `Rng.normalFastFrom(source, T, 0, 1)`.
3. Return X = σ·√(Z₁² + (q·Z₂)²).

The Ω = 0 fast path returns 0 identically. This uses only the existing fast
ziggurat normal and does not require any rejection loop, Bessel evaluation,
or approximation in the hot path.

### Statistical accessors

Moments use closed forms with the existing Bessel helpers:

- **`expectedValue()`**: σ·√(π/2)·(1+q)/2·exp(K)·(I₀(K) + I₁(K)) where
  K = (1−q)²/(4q). At q=1: K=0, exp(0)=1, I₀(0)=1, I₁(0)=0, giving
  σ·√(π/2)·1·1 = σ·√(π/2) — the exact Rayleigh mean. ✓
- **`varianceValue()`**: Ω − (E[X])² (because E[X²] = Ω by construction).
- **`modeValue()`**: σ·q (exact at q=1: σ·1 = σ, matching Rayleigh mode).
- **`sigmaValue()`**: σ = √(Ω/(1+q²)) (the per-component Gaussian scale).
- **`minValue()`**: 0; **`maxValue()`**: null (∞) for Ω > 0; 0 for Ω=0.

### Free-function family

Following the standard alea scalar distribution pattern:

- Scalar sample: `hoyt`, `hoytFrom`, `hoytChecked`, `hoytCheckedFrom`.
- Bulk fill: `fillHoyt`, `fillHoytFrom`, `fillHoytChecked`, `fillHoytCheckedFrom`.

## Tests

Six new tests in `src/distributions.zig`:

1. **Constructor validation** — rejects q = 0, q < 0, q > 1, Ω < 0, NaN, Inf;
   accepts valid (0.5, 1), (1, 2) (q=1 Rayleigh), (0.1, 1), and Ω=0.
2. **q=1 Rayleigh moment equivalence** — for q=1, Ω=2 (σ=1):
   sigmaValue=1, expectedValue=√(π/2) ≈ 1.2533, variance=2−π/2 ≈ 0.4292,
   modeValue=1 — all verified to ~1e-8.
3. **Non-negativity/finiteness** — 200 samples for each q ∈ {0.2, 0.5, 0.8,
   1.0}; all samples ≥ 0 and finite. Ω=0 produces all zeros.
4. **Monte Carlo for q=1 (Rayleigh)** — 5000 samples with mean ≈ √(π/2)
   within 0.06 and second moment ≈ Ω=2 within 0.1.
5. **Free functions and fill** — `fillHoyt` produces non-negative values;
   `hoytChecked` rejects q=0; `hoyt` returns a non-negative sample.
6. **f32 support** — f32 variant at (q=1, Ω=2) produces 64 non-negative
   finite samples with mean ≈ √(π/2) within 1e-3.

All 702 tests pass (18 new across S4-M1257/M1258/M1259).

## Deviations from Rust `rand_distr`

- Rust `rand_distr` does not provide Hoyt/Nakagami-q. Alea extends beyond
  Rust parity here.
- The two-Gaussian product sampler (the defining construction) is used
  directly rather than a Bessel-based rejection method, giving O(1)
  rejection-free sampling that trivially leverages the fast ziggurat normal.
- A standalone `besselI1(z)` is added for the mean accessor (complementing
  the existing `besselI0` and `besselI1Ratio`). Other Bessel-family
  distributions can reuse it.
- The mean formula is the K-parameterized Bessel form which is numerically
  stable across q ∈ (0,1] and exact at q=1.
- Ω=0 is accepted as a degenerate point mass at 0, consistent with other
  fading-family zero-spread conventions (Rice σ=0, Nakagami Ω=0).
- Vector/SIMD variants (VectorHoyt) are deferred; scalar and bulk fill are
  provided.

## Verification

- `zig build test` passes — all 702 tests green.
- `zig build apicheck` passes — all new public symbols documented.
- `zig build roadmapcheck` requires evidence file and closure row.
- `zig build validate` passes all gates.

## Next bar

Noncentral chi/chi-squared, Bingham/Matrix-vMF/Kent directional distributions,
GeneralizedPareto/ScaledInvChiSq/Hoyt/Rice/Nakagami/InverseGamma/ExGaussian
vector/SIMD sampling, copula methods, SIMD spherical bulk paths, weighted/alias
advances, string generation, longer validation runs, broader platform evidence,
or newly discovered core gaps.

## References

- Hoyt, R. S. (1947). Probability functions for the modulus and angle of the
  normal complex variate. *Bell System Technical Journal*, 26(2), 318–359.
- Nakagami, M. (1960). The m-distribution — A general formula of intensity
  distribution of rapid fading. In *Statistical Methods in Radio Wave
  Propagation* (pp. 3–36). Pergamon.
- Simon, M. K. & Alouini, M.-S. (2005). *Digital Communication over Fading
  Channels* (2nd ed.). Wiley. (Chapter 2: Hoyt fading distribution; Bessel
  mean formula; PDF; CDF.)
- Paris, J. F. (2009). Nakagami-q (Hoyt) distribution function with
  applications. In *IEEE Communications Letters*.
- Wikipedia contributors. "Nakagami distribution" and "Hoyt distribution."
  In *Wikipedia*.
- Abramowitz, M. & Stegun, I. A. (1964). *Handbook of Mathematical Functions*.
  (Sections 9.8.1–9.8.4: Bessel I polynomial/asymptotic approximations.)
- Rust `rand_distr` 0.6.0 public surface manifest:
  `compare/results/s4-m294-rand-distr-public-surface-manifest.md`
- Existing Rice/Rayleigh: `Rice(T)`, `besselI0`, `besselI1Ratio` in
  `src/distributions.zig`.
