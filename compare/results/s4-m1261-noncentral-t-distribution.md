# S4-M1261: Noncentral t Distribution

## Milestone

S4-M1261 — Noncentral t distribution: add the noncentral t distribution
t'(ν, μ) with degrees of freedom ν > 0 and noncentrality parameter μ (finite).
This is the distribution of (Z + μ)/√(V/ν) where Z ~ N(0,1) and V ~ χ²(ν)
are independent. It is the canonical distribution for:

- One-sample t-test power analysis under a non-null alternative.
- two-sample t-test power (with noncentrality δ = μ/σ).
- Detection theory and signal-to-noise ratio modeling.
- Two-group experiment sample-size planning.

The PDF involves a confluent hypergeometric function but sampling is
trivially rejection-free as a ratio of existing primitives, requiring only
one standard normal draw and one chi-squared draw per sample — no new
special functions needed for sampling.

Parameter limits:

- μ = 0 → exactly the central StudentT(ν).
- ν = ∞ → exactly N(μ, 1) (standard normal with mean shift).
- ν = 1 → noncentral Cauchy (undefined mean).
- μ → ∞ → distribution shifts away from zero and concentrates.

Moments require a Γ-function ratio (via `std.math.lgamma`):

- c(ν) = √(ν/2) · Γ((ν−1)/2) / Γ(ν/2) for ν > 1 (c(∞) = 1).
- E[T] = μ · c(ν) for ν > 1; undefined (heavy-tail, returns null) for ν ≤ 1.
- Var[T] = ν/(ν−2) · (1 + μ²) − μ² · c(ν)² for ν > 2; null for ν ≤ 2.

## Gap

Local Rust `rand_distr` 0.6.0 provides central StudentT but no noncentral t.
Alea prior to this milestone had StudentT and Normal/ChiSquared primitives
but no composed noncentral t.

## Implementation

### NoncentralT(T) struct

- `init(dof, mu)` validates dof > 0, μ finite, returning `NoncentralTError!Self`.
- `new(dof, mu)` synonym.
- Accessors: `degreesOfFreedomValue`/`dofValue`, `noncentralityValue`/`ncpValue`,
  `muValue`.
- Moments: `expectedValue` returns ?T (null for ν ≤ 1); `varianceValue` returns
  ?T (null for ν ≤ 2); both have fast ν=∞ branches returning μ and 1.
- `minValue`/`maxValue` return null (unbounded support).
- `sample`/`sampleFrom`/`fill`/`fillFrom` delegate to
  `noncentralTPointFrom`/`fillNoncentralTPointsFrom`.

### Internal helpers

- `noncentralTParametersValid(T, dof, mu)` — accepts dof > 0 (including +∞)
  and finite mu.
- `noncentralTScaleFactor(T, dof)` — computes c(ν) via `std.math.lgamma`
  with ν=∞ fast path returning 1.
- `noncentralTPointFrom(source, T, dof, mu)` — if dof is ∞ returns
  `Rng.normalFastFrom(source, T, mu, 1)`; otherwise draws
  `Z = normalFastFrom(source, T, mu, 1)` (i.e. Z+μ in one call) and
  `V = chiSquaredFrom(source, T, dof)`; returns Z·√(dof/V).
- `fillNoncentralTPointsFrom` — fill loop.

### Free-function family

Standard 8-function scalar/fill family:

`noncentralT`, `noncentralTFrom`, `noncentralTChecked`, `noncentralTCheckedFrom`,
`fillNoncentralT`, `fillNoncentralTFrom`, `fillNoncentralTChecked`,
`fillNoncentralTCheckedFrom`.

### Tests (7 new tests)

1. Constructor validation (dof=0, negative dof, infinite μ rejected).
2. μ=0 central-t moment reduction (mean=0 for ν=5, var=5/3; null mean for
   ν=1; null variance for ν=2; ν=∞ mean=2 var=1).
3. 200 samples finite.
4. 5000-sample MC for ν=∞, μ=2 (mean ≈ 2, second moment ≈ 5 = 1+4).
5. 5000-sample MC for μ=0, ν=10 (mean ≈ 0, second moment ≈ 1.25 = 10/8).
6. Free functions / fill / error rejection.
7. f32 support.

## Evidence

- Implementation: `src/distributions.zig` (NoncentralT + 8-function family +
  helpers).
- API reference: `docs/api-reference.md` updated.
- Tests: 7 new tests; 730 total tests pass.
- Validation: `zig build validate` passes all checks.
- Absent from local Rust `rand_distr` 0.6.0.