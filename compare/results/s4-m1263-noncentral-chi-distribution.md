# S4-M1263: Noncentral Chi Distribution

## Milestone

S4-M1263 — Noncentral Chi distribution: add the noncentral chi distribution
χ'(k, λ) with degrees of freedom k ≥ 0 and noncentrality λ ≥ 0. This is the
square root of noncentral chi-squared: X = √(χ'²(k, λ)). It generalizes the
Rayleigh and Rice envelope models to arbitrary degrees of freedom:

- λ = 0 → central Chi(k) (which for k=2 is Rayleigh).
- k = 2, λ = ν² → Rice (Rician) envelope with specular component ν.
- k = 1, λ = μ² → folded normal with mean |μ| for unit variance.
- k = 3 → the 3D Maxwell-Boltzmann distribution generalized to noncentral form.

Sampling is rejection-free as sqrt of noncentral chi-squared:
X = √(noncentralChiSquaredPointFrom(source, T, k, lambda)), composing the new
NoncentralChiSquared helper. No new sampling algorithm is needed.

The expected value requires the confluent hypergeometric function ₁F₁ (Kummer's
function). Alea already has `kummerM(a, b, z, max_terms)` (₁F₁) from the
Watson distribution work, and `std.math.lgamma` for gamma-function ratios.
The closed-form mean is:

    E[X] = √2 · Γ((k+1)/2)/Γ(k/2) · exp(−λ/2) · ₁F₁(1/2; k/2; λ/2)

which at λ=0 reduces to the central chi mean √2·Γ((k+1)/2)/Γ(k/2), matching
the existing `Chi.expectedValue`. A folded-normal branch handles k=0 using
`erfAbramowitzStegun`:

    E[X | k=0] = √λ·erf(√(λ/2)) + √(2/π)·exp(−λ/2)

Variance is computed via the second-moment identity Var[X] = E[X²] − (E[X])² =
(k + λ) − (E[X])² (since E[X²] = E[χ'²(k,λ)] = k + λ).

## Gap

Local Rust `rand_distr` 0.6.0 provides Rayleigh (central chi k=2) and Rice
(which is noncentral chi k=2 with σ=1) but not a general k-dof noncentral chi
distribution. Alea prior to this milestone had Chi (central), Rice (k=2
noncentral via direct two-Gaussian Bessel form), and Rayleigh, but no
general-arity noncentral chi.

## Implementation

### NoncentralChi(T) struct

- `init(k, lambda)` validates k ≥ 0, λ ≥ 0, both finite.
- `new(k, lambda)` synonym.
- Accessors: `degreesOfFreedomValue`/`dofValue`, `noncentralityValue`/`ncpValue`.
- Moments: `expectedValue` returns T (using `noncentralChiExpectedValue`
  helper), `varianceValue` returns T = k+λ − (E[X])².
- `minValue` returns 0, `maxValue` returns null.
- k=0,λ=0 degenerate point mass at 0 is handled as a fast path.
- `sample`/`sampleFrom`/`fill`/`fillFrom` delegate to
  `noncentralChiPointFrom`/`fillNoncentralChiPointsFrom`.

### Internal helpers

- `noncentralChiParametersValid(T, k, lambda)` — parameter check.
- `noncentralChiExpectedValue(T, k, lambda)` — computes the mean using a
  k=0 folded-normal branch (erf + exponential) and the general kummerM +
  lgamma form for k > 0.
- `noncentralChiPointFrom(source, T, k, lambda)` — sqrt of noncentral
  chi-squared point sample.
- `fillNoncentralChiPointsFrom` — fill loop.

### Free-function family

Standard 8-function scalar/fill family:

`noncentralChi`, `noncentralChiFrom`, `noncentralChiChecked`,
`noncentralChiCheckedFrom`, `fillNoncentralChi`, `fillNoncentralChiFrom`,
`fillNoncentralChiChecked`, `fillNoncentralChiCheckedFrom`.

### Tests (6 new tests)

1. Constructor validation (negative k, negative λ rejected; accessors).
2. λ=0 central-Chi moment reduction (E[χ₅] matches Chi.expectedValue to
   1e-9; k=2 Rayleigh mean = √(π/2)).
3. k=2,λ=ν² Rice consistency: non-negativity and variance identity
   Var = k+λ − E[X]².
4. 200 samples non-negative and finite.
5. 5000-sample Monte Carlo second moment = k+λ = 7 for k=3,λ=4.
6. Free functions / fill / error rejection; f32 support.

## Evidence

- Implementation: `src/distributions.zig` (NoncentralChi + 8-function family +
  helpers; reuse of `kummerM`, `std.math.lgamma`, `erfAbramowitzStegun`).
- API reference: `docs/api-reference.md` updated.
- Tests: 6 new tests; 730 total tests pass (28 new tests across the four
  noncentral distributions).
- Validation: `zig build validate` passes all checks.
- Extends beyond local Rust `rand_distr` 0.6.0 which has no general-k
  noncentral chi.