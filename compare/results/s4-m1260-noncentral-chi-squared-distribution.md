# S4-M1260: Noncentral Chi-Squared Distribution

## Milestone

S4-M1260 — Noncentral Chi-Squared distribution: add the noncentral chi-squared
distribution χ'²(k, λ) with degrees of freedom k ≥ 0 and noncentrality parameter
λ ≥ 0 (where λ = Σμᵢ² for the underlying sum Σ(Zᵢ + μᵢ)² of squared shifted
Gaussians). This is the fundamental noncentral distribution for statistical
power analysis, signal detection, Rician fading power, radar, communications,
and option pricing. The PDF is a Poisson mixture of central chi-squareds:

    f(x; k, λ) = Σ_{j=0}^∞ (exp(-λ/2) (λ/2)^j / j!) · f_{χ²(k+2j)}(x)

where f_{χ²(ν)} is the central chi-squared PDF with ν degrees of freedom.

The canonical rejection-free sampler follows directly from this mixture
representation: draw J ~ Poisson(λ/2), then X ~ χ²(k + 2J). Alea composes
its existing `poissonFrom` (Poisson) and `chiSquaredFrom` (central chi-squared,
which itself delegates to the existing Gamma sampler) — no new special
functions are required for sampling.

Parameter limits:

- λ = 0 → exactly central ChiSquared(k).
- k = 0 → mixed distribution: point mass exp(-λ/2) at x = 0 (when J=0) plus
  continuous chi-squared density with 2, 4, 6, ... dof weighted by the Poisson
  probabilities; this represents |N(√λ, 1)|² scaled correctly.
- k = 2, λ = ν² → squared Rician envelope with parameter ν (Rice power).

Moments are closed-form:

- E[X] = k + λ
- Var[X] = 2(k + 2λ)
- Mode = max(0, k + λ − 2)

This milestone also adds NoncentralT, NoncentralF, and NoncentralChi as
follow-up distributions in the same batch since they compose trivially
from NoncentralChiSquared plus existing primitives.

## Gap

Local Rust `rand_distr` 0.6.0 provides no noncentral distributions
(noncentral chi-squared, noncentral t, noncentral F, noncentral chi).
This is a notable statistical-power gap because power analysis for common
hypothesis tests (chi-squared tests, t-tests, ANOVA F-tests) depends on these
distributions. Prior to this milestone Alea also had no noncentral
distributions, despite having all the compositional primitives (Poisson,
ChiSquared, Normal) needed for rejection-free sampling.

## Implementation

### NoncentralChiSquared(T) struct

`NoncentralChiSquared(T)` follows the standard distribution pattern:

- `init(k, lambda)` validates k ≥ 0, λ ≥ 0, both finite, returning
  `NoncentralChiSquaredError!Self` (which aliases `Error`).
- `new(k, lambda)` is a synonym for `init`.
- Accessors: `degreesOfFreedomValue`/`dofValue`, `noncentralityValue`/`ncpValue`.
- Moments: `expectedValue` → T (always k+λ, with point-mass 0 when k=λ=0),
  `varianceValue` → T, `modeValue` → T (max(0, k+λ-2)),
  `minValue` → T = 0, `maxValue` → null.
- `sample`/`sampleFrom`/`fill`/`fillFrom` delegate to
  `noncentralChiSquaredPointFrom`/`fillNoncentralChiSquaredPointsFrom`.
- k=0, λ=0 degenerate point mass at 0 is handled as a fast path.

### Internal helpers

- `noncentralChiSquaredParametersValid(T, k, lambda)` — boolean parameter check.
- `noncentralChiSquaredPointFrom(source, T, k, lambda)` — Poisson-mixture
  sampler: if λ=0 delegates to `chiSquaredFrom`; otherwise J = poissonFrom(λ/2)
  as f64 (poissonFrom takes f64 lambda internally), dof = k + 2·J, delegate to
  `chiSquaredFrom`. An integer-k fast path casts k to u64 and adds 2·J as
  integer for precise dof in the common integer-df case.
- `fillNoncentralChiSquaredPointsFrom(source, T, dest, k, lambda)` — fill loop.

### Free-function family

The standard 8-function scalar/fill family:

`noncentralChiSquared`, `noncentralChiSquaredFrom`,
`noncentralChiSquaredChecked`, `noncentralChiSquaredCheckedFrom`,
`fillNoncentralChiSquared`, `fillNoncentralChiSquaredFrom`,
`fillNoncentralChiSquaredChecked`, `fillNoncentralChiSquaredCheckedFrom`.

### Tests (7 new tests)

1. Constructor validation (negative k, negative λ, infinite k rejected;
   valid construction exposes accessors).
2. Analytic moments (k=5,λ=0 matches central χ² mean=5 var=10 mode=3;
   k=5,λ=2 mean=7 var=18; k=0,λ=0 degenerate at 0).
3. λ=0 reduction: 200 samples non-negative and finite.
4. k=0 special case: 5000-sample MC mean ≈ 4 (k+λ = 4).
5. 5000-sample Monte Carlo for k=3,λ=4 (mean ≈ 7, var ≈ 22).
6. Free functions / fill / error rejection.
7. f32 support.

## Evidence

- Implementation: `src/distributions.zig` (NoncentralChiSquared + 8-function
  family + helpers).
- API reference: `docs/api-reference.md` updated with all new public symbols.
- Tests: 7 new tests in `src/distributions.zig`; 730 total tests pass.
- Validation: `zig build validate` passes (apicheck, distcheck, roadmapcheck,
  examplecheck, readmecheck, statcheck, toolingcheck, profilecheck all green).
- Absent from local Rust `rand_distr` 0.6.0.