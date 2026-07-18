# S4-M1262: Noncentral F Distribution

## Milestone

S4-M1262 — Noncentral F distribution: add the noncentral F distribution
F'(d1, d2, λ) with numerator degrees of freedom d1 > 0, denominator degrees
of freedom d2 > 0, and noncentrality parameter λ ≥ 0. This is the
distribution of the ratio

    F = (X/d1) / (Y/d2),    X ~ χ'²(d1, λ), Y ~ χ²(d2),

i.e. noncentral chi-squared over d1 divided by central chi-squared over d2.
It is the canonical distribution for:

- ANOVA F-test power analysis under an alternative hypothesis.
- Regression F-test power analysis.
- General linear model power calculations (multiple R² F-test).
- Variance-ratio testing under non-null conditions.

Sampling is rejection-free as a ratio of chi-squared draws, composing the
new NoncentralChiSquared helper with the existing ChiSquared sampler. No
new special functions are required.

Parameter limits:

- λ = 0 → exactly the central FisherF(d1, d2).
- d2 → ∞ → (χ'²(d1,λ)/d1) scaled by 1 (noncentral chi-squared/d1).
- d1 → ∞ with fixed λ/d1 → noncentrality concentrated.

Moments (closed-form, return null when undefined due to heavy tails):

- E[F] = d2/(d2−2) · (d1 + λ)/d1   for d2 > 2.
- Var[F] = 2 · ((d1+λ)² + (d1 + 2λ)(d2 − 2)) · d2² / (d1 · (d2−2)² · (d2−4))
          for d2 > 4.

## Gap

Local Rust `rand_distr` 0.6.0 provides central FisherF but no noncentral F.
Alea prior to this milestone had FisherF, ChiSquared, and all the pieces but
no composed noncentral F.

## Implementation

### NoncentralF(T) struct

- `init(d1, d2, lambda)` validates d1 > 0, d2 > 0, λ ≥ 0, all finite.
- `new(d1, d2, lambda)` synonym.
- Accessors: `d1Value`, `d2Value`, `noncentralityValue`/`ncpValue`.
- Moments: `expectedValue` returns ?T (null for d2 ≤ 2), `varianceValue` returns
  ?T (null for d2 ≤ 4).
- `minValue` returns 0; `maxValue` returns null.
- `sample`/`sampleFrom`/`fill`/`fillFrom` delegate to
  `noncentralFPointFrom`/`fillNoncentralFPointsFrom`.

### Internal helpers

- `noncentralFParametersValid(T, d1, d2, lambda)` — parameter check.
- `noncentralFPointFrom(source, T, d1, d2, lambda)` — samples X from
  noncentral chi-squared, Y from central chi-squared, returns (X/d1)/(Y/d2).
- `fillNoncentralFPointsFrom` — fill loop.

### Free-function family

Standard 8-function scalar/fill family:

`noncentralF`, `noncentralFFrom`, `noncentralFChecked`, `noncentralFCheckedFrom`,
`fillNoncentralF`, `fillNoncentralFFrom`, `fillNoncentralFChecked`,
`fillNoncentralFCheckedFrom`.

### Tests (6 new tests)

1. Constructor validation (d1=0, d2=0, negative λ rejected).
2. λ=0 central-F moment reduction (E=1.25 for d1=5,d2=10; null mean for d2≤2;
   null variance for d2≤4; min=0).
3. 200 samples non-negative and finite.
4. 5000-sample MC for λ=0, d2=200 large-denominator (mean ≈ 200/198).
5. 5000-sample MC for d1=3,d2=20,λ=4 (mean ≈ 20/18 · 7/3 ≈ 2.593).
6. Free functions / fill / error rejection; f32 support.

## Evidence

- Implementation: `src/distributions.zig` (NoncentralF + 8-function family +
  helpers).
- API reference: `docs/api-reference.md` updated.
- Tests: 6 new tests; 730 total tests pass.
- Validation: `zig build validate` passes all checks.
- Absent from local Rust `rand_distr` 0.6.0.