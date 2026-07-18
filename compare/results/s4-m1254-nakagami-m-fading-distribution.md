# S4-M1254: Nakagami-m Fading Distribution

## Milestone

S4-M1254 — Nakagami-m distribution: add a two-parameter continuous distribution
on [0, ∞) modeling multipath fading envelope magnitude in wireless/RF
communications. Nakagami-m is parameterized by shape m ≥ 0.5 (the fading
figure) and spread Ω = E[X²] > 0. It is the canonical RF fading model:

- m = 1 recovers Rayleigh(√(Ω/2)) exactly (no line-of-sight, equal-power
  multipath).
- m = 0.5 gives the half-normal (one-sided Gaussian) distribution, modeling
  severe "worse-than-Rayleigh" fading.
- m > 1 approximates Rician fading (mild fading with a dominant line-of-sight
  component); the equivalent K-factor is K ≈ (√(m²−m))/(m−√(m²−m)).
- m → ∞ converges to a Gaussian concentrated near √Ω with variance Ω/(4m).

Sampling is rejection-free via a simple Gamma-plus-sqrt transform:
X = √(Gamma(m, Ω/m)), directly leveraging the existing Gamma sampler — no
new special functions beyond `std.math.lgamma` (already used throughout alea
for Student-t, Fisher-F, Beta, and Chi-squared moment computation).

## Gap

Local Rust `rand`/`rand_distr` does not provide a Nakagami-m distribution.
Alea prior to this milestone had Rayleigh, Maxwell, Rice, and Gamma, but
lacked the Nakagami family that is a staple of wireless communications
literature:

1. No Nakagami-m distribution for fading-channel simulations, radar clutter
   modeling, ultrasound speckle, or medical image intensity modeling.
2. No simple Gamma-sqrt transform wrapper exposing the fading-family
   shape/spread parameterization used by the RF community.
3. Hoyt (Nakagami-q) distribution (a related one-parameter model for
   unequal-power I/Q fading) remains deferred to a follow-up.

## Implementation

### NakagamiError

`NakagamiError` aliases the generic `Error` set (`error.InvalidParameter`),
consistent with other two-parameter continuous distributions whose validation
checks are non-negativity/finiteness (plus the m ≥ 0.5 shape bound).

### Nakagami(T) struct

`Nakagami(T)` follows the canonical continuous-distribution struct pattern:

- `comptime requireFloat(T);`
- `init(m_param, omega)` — validates m ≥ 0.5, Ω ≥ 0, both finite (zero Ω
  accepted as a degenerate point mass at 0).
- `new(m_param, omega)` — panics in debug on invalid parameters.
- Accessors: `shapeValue()` / `mValue()` (the fading figure), `spreadValue()`
  / `omegaValue()` (Ω = E[X²]), `equivalentRayleighScale()` (√(Ω/2)),
  `expectedValue()`, `varianceValue()`, `modeValue()`, `minValue()`,
  `maxValue()`.
- Samplers: `sample(rng)`, `sampleFrom(source)`, `fill(rng, dest)`,
  `fillFrom(source, dest)`.

### Algorithm

Sampling is rejection-free and O(1):

1. Draw Y ~ Gamma(shape=m, scale=Ω/m) via the existing `gammaFrom`.
2. Return √Y.

Fast paths:
- **Ω = 0:** point mass at 0 (no RNG draws).
- **m = 1:** the sampler automatically produces Rayleigh samples (since
  Gamma(1, Ω/1) = Exp(Ω) and √(Exp(Ω/1))·√(2/Ω) = Rayleigh(√(Ω/2)), which
  matches the identity). Moments use exact closed-form Rayleigh expressions
  for numerical precision at the boundary.

### Statistical accessors

All moment formulas use `std.math.lgamma` (log Γ) for stable ratio
computation, avoiding overflow in the gamma-function ratio:

- **`expectedValue()`**:
  - Ω=0 → 0.
  - m=1 → √(πΩ)/2 (exact Rayleigh mean).
  - General case: (Γ(m+½)/Γ(m)) · √(Ω/m), computed as
    `exp(lgamma(m+½) − lgamma(m)) · √(Ω/m)`.
- **`varianceValue()`**:
  - Ω=0 → 0.
  - m=1 → Ω·(4−π)/4 (exact Rayleigh variance).
  - General case: Ω · (1 − (Γ(m+½)/Γ(m))²/m).
- **`modeValue()`**:
  - Ω=0 → 0.
  - m < 1 → 0 (the density diverges at 0 for sub-Rayleigh fading).
  - m=1 → √(Ω/2) (exact Rayleigh mode = σ).
  - m > 1 → √(Ω·(m−1)/m).
- **`minValue()`**: 0; **`maxValue()`**: null (∞) for Ω>0, 0 for Ω=0.
- **`equivalentRayleighScale()`**: √(Ω/2), the σ that would give Rayleigh
  fading with the same second moment. Useful for comparing Nakagami to
  Rayleigh/Rice parameterizations.

### Free-function family

Following the standard alea scalar distribution pattern:

- Scalar sample: `nakagami`, `nakagamiFrom`, `nakagamiChecked`,
  `nakagamiCheckedFrom`.
- Bulk fill: `fillNakagami`, `fillNakagamiFrom`, `fillNakagamiChecked`,
  `fillNakagamiCheckedFrom`.

`*From` variants accept a custom source; `*Checked` variants return a
`NakagamiError` union; non-Checked variants use `.new()` (panic in debug on
invalid parameters).

## Tests

Eight new tests in `src/distributions.zig`:

1. **Constructor validation** — rejects m < 0.5 (0.4), Ω < 0 (−1), NaN,
   Inf; accepts m=1 (Rayleigh case), Ω=0 (point mass), and the m=0.5
   boundary (half-normal).
2. **m=1 reduces to Rayleigh moments** — mean matches √(πΩ)/2 to 1e-12
   (Ω=2 → σ=1), variance matches (4−π)/2 to 1e-12, mode = 1,
   equivalentRayleighScale = 1.
3. **Ω=0 point mass** — all samples equal 0; mean = 0; variance = 0;
   mode = 0.
4. **Non-negativity across shape range** — 1200 samples (200 each for
   m ∈ {0.5, 0.75, 1, 2, 5, 10}) at Ω=4 are all ≥ 0 and finite.
5. **m=0.5 half-normal moments with Monte Carlo** — with Ω=1 (σ=1 for
   the half-normal), expected mean = √(2/π) ≈ 0.798 and expected variance
   = 1 − 2/π ≈ 0.363; 5000-sample Monte Carlo gives mean within 0.04 and
   variance within 0.05; mode = 0 (analytically correct for half-normal).
6. **Large-m concentration** — at m=50, Ω=4 (√Ω=2), E[X] ≈ 2 within 0.01,
   variance < 0.03 (Ω/(4m) = 0.02 bound), mode ≈ 2 within 0.03;
   2000-sample Monte Carlo mean ≈ 2 within 0.05.
7. **Free functions and fill** — `fillNakagamiChecked` produces non-negative
   values; `nakagamiChecked` rejects m=0.3; `nakagami` returns a finite
   non-negative value.
8. **f32 support** — f32 variant at m=1, Ω=2 produces 64 non-negative
   finite samples with mean matching √(π/2) to within 1e-4.

All 668 tests pass (660 pre-existing + 8 new).

## Deviations from Rust `rand_distr`

- Rust `rand_distr` does not provide Nakagami-m. Alea extends beyond parity
  here (as it did with Truncated Normal, Von Mises, Wrapped Cauchy,
  Von Mises-Fisher, Watson, and Rice).
- The shape parameter is named `m` (the standard Nakagami fading figure)
  rather than a generic name; both `shapeValue()` and `mValue()` accessors
  are provided for API clarity.
- The spread parameter is named `Ω` (omega), the conventional symbol for
  E[X²] in Nakagami literature; both `spreadValue()` and `omegaValue()`
  accessors are provided.
- The `equivalentRayleighScale()` accessor provides a direct bridge to
  Rayleigh σ, useful for code that mixes Rayleigh and Nakagami fading
  models at the same second-moment power.
- Vector/SIMD variants (VectorNakagami) are deferred; the scalar and bulk
  fill APIs provide the full scalar/fill surface consistent with the
  recently-added Rice pattern. Vector variants can be added later without
  breaking the API.

## Verification

- `zig build test` passes — all 668 tests green.
- `zig build apicheck` passes — all 26 new public symbols documented in
  `docs/api-reference.md`.
- `zig build roadmapcheck` requires `compare/results/s4-m1254-nakagami-m-fading-distribution.md`
  and a `| S4-M1254 | Nakagami-m fading distribution` closure row in
  `core-rand-coverage.md`.
- `zig build validate` passes all gates (apicheck, readmecheck, examplecheck,
  toolingcheck, distcheck, statcheck, roadmapcheck).

## Next bar

Noncentral chi/chi-squared, Inverse Gamma, Exponentially Modified Gaussian
(ExGaussian), Generalized Pareto, Hoyt (Nakagami-q) fading, additional
directional/multivariate distributions (Bingham, Matrix von Mises-Fisher,
Kent), Rice/Nakagami vector/SIMD sampling, copula methods, SIMD spherical
bulk paths, weighted/alias advances, string generation expansion, longer
validation runs, broader platform evidence, or newly discovered core gaps.

## References

- Nakagami, M. (1960). "The m-distribution — A general formula of intensity
  distribution of rapid fading." In W. C. Hoffman (Ed.), *Statistical Methods
  in Radio Wave Propagation* (pp. 3–36). Pergamon Press.
- Simon, M. K. & Alouini, M.-S. (2005). *Digital Communication over Fading
  Channels* (2nd ed.). Wiley-IEEE Press. (Nakagami-m chapter; K-factor
  equivalence with Rice.)
- Yacoub, M. D. (2007). "The κ-μ and η-μ distributions." *IEEE Antennas and
  Propagation Magazine*, 49(1), 68–81. (Nakagami as special case of more
  general fading models.)
- Shankar, P. M. (2017). *Fading and Shadowing in Wireless Systems* (2nd ed.).
  Springer.
- Rust `rand_distr` 0.5.1/0.6 public surface manifest:
  `compare/results/s4-m294-rand-distr-public-surface-manifest.md`
- Existing Gamma distribution: `Gamma(T)` / `gammaFrom` in `src/distributions.zig`.
- Existing Rayleigh distribution: `Rayleigh(T)` in `src/distributions.zig`.
- Preceding fading-family milestone: S4-M1253 (Rice/Rician).