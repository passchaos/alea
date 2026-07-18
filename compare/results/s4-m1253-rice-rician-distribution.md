# S4-M1253: Rice (Rician) Fading Distribution

## Milestone

S4-M1253 — Rice (Rician) distribution: add a noncentral-chi-with-2-DOF
distribution modeling X = √((Z₁+ν)² + Z₂²) for independent Z₁,Z₂∼N(0,σ²).
The Rice (or Rician) distribution is ubiquitous in signal processing (Rician
fading channels with a line-of-sight component), MRI (Rician noise in magnitude
MR images), radar target detection, and optics (speckle with coherent
component). It generalizes Rayleigh (ν=0, no line-of-sight), collapses to a
point mass at ν when σ=0, and approximates N(ν,σ²) at high SNR (ν≫σ).
Sampling is rejection-free (two independent normals + a sqrt), making the
distribution both algorithmically simple and practically high-value.

## Gap

Local Rust `rand`/`rand_distr` does not provide a Rice distribution. The
`rand_distr` 0.6 public surface covers Rayleigh but not its noncentral
generalization. Alea prior to this milestone had Rayleigh, Maxwell (chi with
3 DOF), and Chi/ChiSquared, but lacked the noncentral chis and the specific
high-utility 2-DOF noncentral case (Rice):

1. No Rice/Rician distribution for fading-channel, MRI, radar, or speckle
   simulations.
2. No Nakagami-m distribution (a related generalization, deferred).
3. No NoncentralChi/NoncentralChiSquared distributions (general k-DOF
   noncentral chis, deferred to follow-up).
4. No modified Bessel I₀ helper beyond the I₁/I₀ ratio used by VonMises.

## Implementation

### besselI0 and logBesselI0 helpers

Two file-private helpers implement the modified Bessel function of the first
kind of order 0, I₀(z), and its logarithm:

- **`besselI0(z)`**: Abramowitz & Stegun approximations:
  - Small |z| ≤ 3.75: polynomial in (z/3.75)² accurate to ~1e-7 (A&S 9.8.1).
  - Large |z| > 3.75: asymptotic expansion exp(|z|)/√(2π|z|) · P(3.75/|z|)
    with a 7-term rational correction polynomial (A&S 9.8.2).
  - Evenness: I₀(−z) = I₀(z).
- **`logBesselI0(z)`**: For |z| ≤ 30 uses @log(besselI0(z)); for |z| > 30 uses
  the direct asymptotic log I₀(z) ≈ |z| − ½·log(2π|z|) + 1/(8|z|) − 1/(16z²)
  to avoid overflow of exp(z) in the raw besselI0 at large arguments. Used
  by Rice.expectedValue for high-SNR stability.

### RiceError

`RiceError` aliases the generic `Error` set (i.e., `error.InvalidParameter`),
consistent with other two-parameter continuous distributions whose parameters
are non-negativity/finiteness checks.

### Rice(T) struct

`Rice(T)` follows the canonical continuous-distribution struct pattern:

- `comptime requireFloat(T);`
- `init(nu, sigma)` — validates ν ≥ 0, σ ≥ 0, both finite (zero σ accepted
  as a degenerate point mass).
- `new(nu, sigma)` — panics in debug on invalid parameters.
- Accessors: `noncentralityValue()`, `scaleValue()`, `kFactor()` (K = ν²/(2σ²),
  the Rician K-factor used in fading-channel literature in dB-like linear
  form), `expectedValue()`, `varianceValue()`, `modeValue()`, `minValue()`,
  `maxValue()`.
- Samplers: `sample(rng)`, `sampleFrom(source)`, `fill(rng, dest)`,
  `fillFrom(source, dest)`.

### Algorithm

Sampling is rejection-free:

1. Draw X₁∼N(ν, σ²), X₂∼N(0, σ²) via two `normalFastFrom` calls.
2. Return √(X₁² + X₂²).

Fast paths:
- **σ = 0:** point mass at ν (no RNG draws).
- **ν = 0:** not special-cased in the sampler (two normals + sqrt works and
  gives exact Rayleigh samples), but moments use closed-form Rayleigh
  expressions (σ√(π/2) and (4−π)σ²/2) for exactness.

### Statistical accessors

- **`expectedValue()`**:
  - σ=0 → ν.
  - ν=0 → σ·√(π/2) (exact Rayleigh mean).
  - General case: σ·√(π/2)·exp(−t)·((1+2t)·I₀(t) + 2t·I₁(t)) where
    t = ν²/(4σ²), with exp(−t + log I₀(t)) computed via log-space to avoid
    overflow for large SNR. I₁/I₀ comes from the existing `besselI1Ratio`.
- **`varianceValue()`**: 2σ² + ν² − (E[X])², a standard Rice identity.
- **`modeValue()`**: exact mode satisfies x·I₀(xν/σ²)/(ν·I₁(xν/σ²)) = 1.
  We use SNR-dependent approximations:
  - σ=0 → ν.
  - ν=0 → σ (exact Rayleigh mode).
  - High SNR (ν/σ > 10): ν·(1 − 1/(2(ν/σ)²)), accurate to <1%.
  - Low SNR (ν/σ < 0.3): σ (Rayleigh limit).
  - Transition: √(max(σ², ν²−σ²)).
- **`minValue()`**: 0; **`maxValue()`**: null (∞) for σ>0, ν for σ=0.
- **`kFactor()`**: K = ν²/(2σ²), returning +∞ when σ=0, consistent with
  the deterministic line-of-sight case.

### Free-function family

Following the standard alea scalar distribution pattern:

- Scalar sample: `rice`, `riceFrom`, `riceChecked`, `riceCheckedFrom`.
- Bulk fill: `fillRice`, `fillRiceFrom`, `fillRiceChecked`, `fillRiceCheckedFrom`.

`*From` variants accept a custom source; `*Checked` variants return a
`RiceError` union; non-Checked variants use `.new()` (panic in debug on
invalid parameters).

## Tests

Eight new tests in `src/distributions.zig`:

1. **Constructor validation** — rejects ν<0, σ<0, NaN, Inf; accepts ν=0, σ=0.
2. **ν=0 reduces to Rayleigh moments** — mean matches σ√(π/2) to 1e-12,
   variance matches (4−π)σ²/2 to 1e-12, mode = σ.
3. **σ=0 point mass** — all samples equal ν; mean = ν; variance = 0.
4. **Non-negativity** — 500 samples at (ν=2,σ=1) are all ≥ 0 and finite.
5. **High-SNR concentration** — at (ν=20, σ=1, K=200 linear ≈ 23 dB),
   E[X] ≈ 20 within 0.03, variance ≈ 1 within 0.1; 2000-sample mean ≈ 20
   within 0.1.
6. **Free functions and fill** — `fillRiceChecked` produces non-negative
   values; `riceChecked` rejects negative ν; `rice` returns a finite value.
7. **f32 support** — f32 variant produces 64 non-negative finite samples.
8. **besselI0 sanity** — I₀(0)=1; I₀(1)≈1.266 within 1e-6; I₀(3)≈4.881
   within 1e-5; I₀(−2.5)=I₀(2.5) (evenness); I₀(50) > 1e20 and finite.

All 660 tests pass (652 pre-existing + 8 new).

## Deviations from Rust `rand_distr`

- Rust `rand_distr` does not provide Rice. Alea extends beyond parity here
  (as it did with Truncated Normal, Von Mises, Wrapped Cauchy, Von Mises-
  Fisher, and Watson).
- The K-factor accessor is named `kFactor()` returning K = ν²/(2σ²) (the
  conventional fading definition K = (power in LOS path)/(power in scattered
  paths) = ν²/(2σ²)).
- `besselI0` and `logBesselI0` are file-private infrastructure (not exported)
  since they are also useful for future noncentral chi/chi-squared and
  Bingham distributions.
- Moments use exact Bessel expressions rather than Laguerre-polynomial form
  because the I₀+I₁ form is cheaper to evaluate with existing helpers.

## Verification

- `zig build test` passes — all 660 tests green.
- `zig build apicheck` passes — all 24 new public symbols documented in
  `docs/api-reference.md`.
- `zig build roadmapcheck` requires `compare/results/s4-m1253-rice-rician-distribution.md`
  and a `| S4-M1253 | Rice (Rician) fading distribution` closure row in
  `core-rand-coverage.md`.
- `zig build validate` passes all gates (apicheck, readmecheck, examplecheck,
  toolingcheck, distcheck, statcheck, roadmapcheck).

## Next bar

Nakagami-m distribution, noncentral chi/chi-squared, Bingham/Matrix-vMF/Kent
directional distributions, Rice vector/SIMD sampling, copula methods, SIMD
spherical bulk paths, weighted/alias advances, string generation expansion,
longer validation runs, broader platform evidence, or newly discovered core
gaps.

## References

- Rice, S. O. (1944, 1945). "Mathematical analysis of random noise."
  *Bell System Technical Journal*, 23(3), 282–332 and 24(1), 46–156.
- Abramowitz, M. & Stegun, I. A. (1964). *Handbook of Mathematical Functions*.
  (Modified Bessel functions I₀, Chapter 9.)
- Papoulis, A. & Pillai, S. U. (2002). *Probability, Random Variables, and
  Stochastic Processes* (4th ed.). McGraw-Hill. (Rician fading, Section 6-3.)
- Gudbjartsson, H. & Patz, S. (1995). "The Rician distribution of noisy MRI
  data." *Magnetic Resonance in Medicine*, 34(6), 910–914.
- Rust `rand_distr` 0.6.0 public surface manifest:
  `compare/results/s4-m294-rand-distr-public-surface-manifest.md`
- Existing VonMises (besselI1Ratio) implementation: S4-M1246.
- Existing Rayleigh distribution: `Rayleigh(T)` in `src/distributions.zig`.
