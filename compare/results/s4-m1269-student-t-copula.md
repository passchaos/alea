# S4-M1269 — Student-t copula, regularized incomplete beta, and Student-t CDF

## Goal

Add a Student-t copula on the unit hypercube `(0,1)^dimension`:

```
z ~ N(0, R),   s ~ χ²(ν),   t_i = z_i / √(s/ν),   u_i = F_ν(t_i),
```

where `R` is a symmetric positive-semidefinite correlation matrix and `ν > 0`
is the degrees of freedom. The shared chi-squared scale induces symmetric tail
dependence, the property that distinguishes the t-copula from the Gaussian
copula and makes it the standard model for joint extreme events in finance and
risk management. Neither the t-copula nor the Student-t CDF exists in local
Rust `rand` / `rand_distr` core.

## Implementation

### Public API

Mathematical helpers:

- `betaIncomplete(x, a, b)` — regularized incomplete beta `I_x(a,b)` for
  `0 ≤ x ≤ 1`, `a, b > 0`, using the continued-fraction representation with
  the symmetry `I_x(a,b) = 1 − I_{1−x}(b,a)`.
- `studentTCdf(t, nu)` — Student-t CDF via
  `F(t) = 1 − ½·I_{ν/(ν+t²)}(ν/2, ½)` for `t ≥ 0` and
  `F(t) = ½·I_{ν/(ν+t²)}(ν/2, ½)` for `t < 0`. Uses `normCdf` directly for
  `ν > 1e6` to avoid `lgamma` cancellation in the far-normal limit.

`StaticStudentTCopula(T, dimension)` (comptime dimension ≥ 1):

- `init(correlation, degrees_of_freedom) StudentTCopulaError!Self` /
  `new(correlation, degrees_of_freedom) Self`
- `correlationValue(self) [dimension][dimension]T`
- `degreesOfFreedomValue(self) T`, `dfValue(self) T`
- `dimensionValue(self) usize`
- `sample(self, rng) [dimension]T`, `sampleFrom(self, source) [dimension]T`
- `fill(self, rng, dest) void`, `fillFrom(self, source, dest) void`

Free-function family:

- `studentTCopula`, `studentTCopulaFrom`, `studentTCopulaChecked`,
  `studentTCopulaCheckedFrom`
- `fillStudentTCopula`, `fillStudentTCopulaFrom`,
  `fillStudentTCopulaChecked`, `fillStudentTCopulaCheckedFrom`

`StudentTCopulaError` aliases the distribution `Error` set. The `multi`
namespace re-exports `StaticStudentTCopula`.

### Validation and sampling

1. Reject non-positive/non-finite degrees of freedom.
2. Validate and symmetrize the correlation matrix through the shared
   `staticCopulaCorrelation` helper added with the Gaussian copula (finite
   entries, unit diagonal, `[-1,1]` range).
3. Delegate positive-semidefinite factoring and rank-deficient support to
   `StaticMultivariateNormal(T, dimension)`.
4. Draw `z ~ N(0, R)` and `s ~ χ²(ν)` (reusing `chiSquaredFrom`), then map
   `t_i = z_i / √(s/ν)` through `studentTCdf`.
5. Clamp uniforms to `(ε/2, 1−ε/2)`.

The sampler is allocation-free and deterministic for a given engine and
parameter set.

## Tests added (10 new, total 789)

1. `studentTCdf matches known values and symmetry` — exact `ν=1` values,
   `ν=2` closed form, tabulated `ν=5/7/10` values, symmetry, large-ν normal
   limits (`1e5` and `1e7`), and f32 support.
2. `StudentTCopula constructor validates parameters` — df `0`, negative, NaN,
   infinity, and invalid correlation.
3. `StudentTCopula with identity correlation has uniform marginals` — mean,
   variance, and independent cross moment over 5,000 samples.
4. `StudentTCopula with perfect correlation returns equal uniforms` — rank-1
   correlation.
5. `StudentTCopula exhibits lower-tail dependence` — 20,000 samples with
   ρ=0.8, ν=3; joint lower-tail rate far above the independence baseline.
6. `StudentTCopula large degrees of freedom approaches the Gaussian copula` —
   ν=1e7 cross moment matches the exact arcsin formula.
7. `StudentTCopula free functions and fill work` — fill, checked, and
   invalid-parameter paths.
8. `StudentTCopula direct-source sampling matches facade`.
9. `StudentTCopula f32 sampling works`.
10. `Gaussian copula cross moment matches the exact arcsin formula` — the
    exact `E[Φ(X)Φ(Y)] = 1/4 + arcsin(ρ/2)/(2π)` identity, added while
    validating the shared copula infrastructure.

## Validation

- `zig build test` passes: 789/789 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- Focused `zig test src/root.zig --test-filter "opula"` passes all matching
  copula tests; `--test-filter "studentT"` passes the CDF tests.
- `docs/api-reference.md` updated for all 25 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1269 row added.

## Deviations and notes

- `betaIncomplete` is a general special function exposed publicly because it
  is also the natural building block for Beta/F CDF work; it is implemented
  with the Numerical Recipes continued fraction and a 300-iteration safety
  cap.
- The t-copula uses the same correlation matrix for the underlying normal and
  the t-marginals, as required by the standard multivariate-t construction.
  The `dfValue` alias mirrors the naming used by the noncentral and
  scaled-inverse-chi-squared families.
- Only the comptime-dimension static variant is provided; a dynamic variant
  can follow the `MultivariateNormal(T)` pattern if runtime dimensions are
  needed.
- The inverse Student-t CDF is not provided, so users who need t-marginal
  quantiles must supply their own inverse CDF; the copula API returns uniforms
  precisely so arbitrary marginals remain composable.

## Next bar

Matrix von Mises-Fisher, Kent distribution, dynamic-dimension copulas,
vector/SIMD copula or Bingham sampling, longer statistical validation runs, or
newly discovered core gaps against local Rust `rand` / `rand_distr` evidence.
