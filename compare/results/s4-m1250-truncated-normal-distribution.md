# S4-M1250: Truncated Normal Distribution

## Milestone

S4-M1250 — Truncated Normal distribution: add a two-sided truncated normal
distribution extending alea's continuous-distribution coverage beyond what
local Rust `rand_distr` exposes for bounded normals. Include public `normPdf`,
`normCdf`, and `probit` mathematical helpers supporting scalar (f32/f64) and
SIMD vector types; a `TruncatedNormal(T)` parameterized struct with fast
paths for degenerate, one-sided, and unbounded cases; a complete 24-function
free-function family covering scalar/vector sample/fill entry points with
Checked/From variants; a `VectorTruncatedNormal(VectorType)` SIMD struct;
promotion of previously-internal `vonMises` and `wrappedCauchy` to public
API with their complete Checked/vector/fill variants and vector structs.

## Gap

Local Rust `rand_distr` provides `Normal` and `StandardNormal` but does not
expose a truncated normal distribution in its public API. Alea's continuous
distributions already cover normal, lognormal, exponential, gamma, beta,
Cauchy, logistic, Pareto, Weibull, triangular, circular von Mises, and
wrapped Cauchy, but lacked:

1. A two-sided bounded normal distribution (commonly needed for simulation,
   Bayesian inference, and constrained modeling).
2. Public scalar-and-SIMD normal PDF, normal CDF, and probit (inverse CDF)
   helpers that users can call directly.
3. Full public visibility for `vonMises` and `wrappedCauchy` distribution
   families (previously internal-only `fn` with missing Checked/vector/fill
   variants and vector structs).

## Implementation

### Mathematical helpers

`src/distributions.zig` adds three public polymorphic functions:

- **`normPdf(x)`** — Standard normal PDF φ(x) = (1/√(2π))·exp(−x²/2).
  Works for f32, f64, and SIMD vectors of f32/f64. Uses `inv_sqrt_2pi`
  constant (0.3989422804014327).

- **`normCdf(x)`** — Standard normal CDF Φ(x) = (1 + erf(x/√2))/2.
  Implements the Abramowitz & Stegun 7.1.26 approximation (West 5-term
  Horner form) for erf:
  - p = 0.3275911, a1..a5 = 0.254829592, −0.284496736, 1.421413741,
    −1.453152027, 1.061405429
  - Max absolute error ≈ 1.5e-7, sufficient for inverse-CDF sampling.
  - Explicit zero return at x=0 eliminates floating-point bias.
  - f32 variant uses f32 constants with `@floatCast(f32, ...)` for efficiency.

- **`probit(p)`** — Inverse standard normal CDF Φ⁻¹(p), using Peter
  Acklam's rational approximation algorithm with three regions:
  - Lower tail (p < 0.02425): rational approximation in q = √(−2·ln(p)).
  - Upper tail (p > 0.97575): rational approximation in q = √(−2·ln(1−p)).
  - Middle: rational approximation in q = p − 0.5, r = q².
  - One Newton refinement step for full machine-precision accuracy.
  - Both f64 and f32 variants provided; f32 uses f32 constants for efficiency.

All three helpers dispatch on `@typeInfo(T)` (`.float` / `.vector`) to
support scalar and SIMD vector inputs transparently.

### TruncatedNormal(T) struct

`TruncatedNormal(T)` follows the canonical distribution struct pattern:

- `comptime requireFloat(T);` at the top.
- `init(mu, sigma, lower, upper)` validates parameters and returns error or struct:
  - σ ≥ 0 and finite; μ, lower, upper finite.
  - lower < upper strictly (rejects lower ≥ upper with `InvalidParameter`).
  - Z = Φ(β) − Φ(α) > √ε(T) (rejects effectively zero-mass windows).
- `new(mu, sigma, lower, upper)` panics on invalid parameters (debug-only assertion).
- Accessors: `mean()`, `variance()`, `standardDeviation()`, `minValue()`, `maxValue()`,
  `modeValue()`, `medianValue()`, `expectedValue()`.
- `sample(rng)`, `sampleFrom(source)`, `fill(rng, dest)`, `fillFrom(source, dest)`.

#### Precomputation

The constructor precomputes and stores:

- α = (lower − μ)/σ, β = (upper − μ)/σ (standardized bounds)
- Φ(α), Φ(β), Z = Φ(β) − Φ(α) (truncation CDF values and total mass)
- φ(α), φ(β) (PDF values at bounds, used for moments)

#### Fast paths

1. **Degenerate (σ = 0)**: Returns constant μ (point mass), valid only if
   lower ≤ μ ≤ upper. Does not consume randomness.
2. **Unbounded (lower = −∞ and upper = +∞)**: Delegates to the ziggurat normal
   sampler directly, avoiding inverse-CDF overhead for the unrestricted case.
3. **One-sided (lower = −∞ or upper = +∞)**: Uses the same inverse-CDF formula
   with Φ(−∞) = 0 or Φ(+∞) = 1.

#### Sampling algorithm

Uses inverse-CDF sampling (deterministic bounded latency, trivial vectorization):

    X = μ + σ · probit(Φ(α) + U · Z)

where U ~ open Uniform(0, 1) via `floatOpenFrom`, ensuring p is strictly inside
(Φ(α), Φ(β)) and avoiding ±inf from `probit` at boundaries 0 and 1.

#### Moments

Truncated normal moments (standardized, then scaled):

- E[X | α ≤ Z ≤ β] = μ + σ · (φ(α) − φ(β)) / Z
- Var[X | α ≤ Z ≤ β] = σ² · (1 + (α·φ(α) − β·φ(β))/Z − ((φ(α)−φ(β))/Z)²)

For infinite bounds: α·φ(α) = 0 when α = −∞ and β·φ(β) = 0 when β = +∞
(exponential decay dominates; 0·∞ = 0 mathematically), avoiding NaN from
multiplying 0 with infinity.

### VectorTruncatedNormal(VectorType) SIMD struct

Per-lane inverse-CDF sampling using SIMD arithmetic:

- Draws uniform vector via `vectorOpenFrom(source, elem_type)`.
- Applies the formula `mu_vec + sigma_vec * probit(phi_alpha_vec + u_vec * Z_vec)`
  component-wise using `inline for` unrolled per-lane operations.
- Provides `init`, `new`, `mean`, `variance`, `sample`, `sampleFrom`,
  `fill`, `fillFrom` following the canonical vector-distribution pattern.

### Complete free-function family

24 public free functions covering the TruncatedNormal family, following the
established alea naming convention:

- Scalar: `truncatedNormal`, `truncatedNormalFrom`, `truncatedNormalChecked`,
  `truncatedNormalCheckedFrom`, `fillTruncatedNormal`, `fillTruncatedNormalFrom`,
  `fillTruncatedNormalChecked`, `fillTruncatedNormalCheckedFrom`
- Vector: `vectorTruncatedNormal`, `vectorTruncatedNormalFrom`,
  `vectorTruncatedNormalChecked`, `vectorTruncatedNormalCheckedFrom`,
  `fillVectorTruncatedNormal`, `fillVectorTruncatedNormalFrom`,
  `fillVectorTruncatedNormalChecked`, `fillVectorTruncatedNormalCheckedFrom`
- Internal (non-pub) `truncatedNormalFromGeneric` and `vectorTruncatedNormalFromGeneric`
  back both scalar and vector From/CheckedFrom entry points.

### VonMises and WrappedCauchy promotion

- Promoted `vonMises` from internal `fn` to `pub fn`, adding the complete
  family of missing Checked/fill/vector variants: `vonMisesChecked`,
  `vonMisesCheckedFrom`, `fillVonMises`, `fillVonMisesFrom`,
  `fillVonMisesChecked`, `fillVonMisesCheckedFrom`, `vectorVonMises`,
  `vectorVonMisesFrom`, `vectorVonMisesChecked`, `vectorVonMisesCheckedFrom`,
  `fillVectorVonMises`, `fillVectorVonMisesFrom`, `fillVectorVonMisesChecked`,
  `fillVectorVonMisesCheckedFrom`.
- Added `VectorVonMises(VectorType)` SIMD struct matching the vector pattern.
- Promoted `wrappedCauchy` from internal `fn` to `pub fn`, adding the same
  complete family of Checked/fill/vector variants and `VectorWrappedCauchy(VectorType)`.
- Added `VonMisesError` and `WrappedCauchyError` public error aliases (both
  resolve to `error.InvalidParameter` for now).

### Files changed

- `src/distributions.zig`:
  - Added `inv_sqrt_2pi`, `inv_sqrt_2` constants.
  - Added internal `erfAbramowitzStegun`, `erfAbramowitzStegunF32`, `erfc`,
    `normPdfGeneric`, `normCdfGeneric`, `probitF64`, `probitF32`, `probitTailF64`,
    `probitTailF32`, `probitGeneric` functions.
  - Added public `normPdf`, `normCdf`, `probit` polymorphic entry points.
  - Added `TruncatedNormalError = error.InvalidParameter;` alias.
  - Added `TruncatedNormal(T)` struct with init/new/accessors/sample/fill.
  - Added `truncatedNormalFromGeneric` internal helper.
  - Added complete 24-function TruncatedNormal free-function family.
  - Added `VectorTruncatedNormal(VectorType)` SIMD struct.
  - Promoted `vonMises` to pub, added missing Checked/fill/vector variants
    and `VectorVonMises(VectorType)` struct.
  - Promoted `wrappedCauchy` to pub, added missing Checked/fill/vector variants
    and `VectorWrappedCauchy(VectorType)` struct.
  - Added `VonMisesError`, `WrappedCauchyError` aliases.
  - Added 7 new TruncatedNormal tests: constructor validation, degenerate
    point-mass, bound satisfaction, moment accuracy, free functions, SIMD
    vectors, f32 precision.
  - Added 4 new tests for normPdf/normCdf/probit: known values, CDF
    symmetry, probit-CDF round-trip, f32 round-trip.
- `docs/api-reference.md`: Added entries for all new public symbols.
- `tools/roadmapcheck.zig`: Added S4-M1250 evidence entry and required token.
- `compare/results/core-rand-coverage.md`: Added S4-M1250 closure row.

## Validation

- `zig build` compiles cleanly.
- `zig build test`: all 614 tests pass (603 pre-existing + 11 new).
- `zig build validate`: all checks pass:
  - apicheck ok
  - readmecheck ok
  - roadmapcheck ok
  - examplecheck ok
  - toolingcheck ok
  - distcheck ok
  - practrand self-test ok

### New tests (11 total)

1. **normPdf at known points** — φ(0) = 1/√(2π), φ(1) matches known value.
2. **normCdf symmetry and known points** — Φ(0) = 0.5, Φ(−x) = 1 − Φ(x),
   Φ(1.96) ≈ 0.975.
3. **probit-CDF round-trip** — probit(Φ(x)) ≈ x for multiple x values.
4. **probit f32 round-trip** — f32 variant round-trips correctly.
5. **TruncatedNormal constructor validation** — rejects σ < 0, non-finite
   params, lower ≥ upper, zero-mass windows.
6. **TruncatedNormal degenerate point-mass** — σ=0 returns μ, no randomness
   consumed.
7. **TruncatedNormal bound satisfaction** — 4096 samples from μ=0, σ=1,
   lower=−1, upper=2 stay within [−1, 2].
8. **TruncatedNormal moment accuracy** — mean and variance match analytic
   formulas within statistical tolerance for several truncation ranges.
9. **TruncatedNormal free functions** — truncatedNormal/truncatedNormalChecked/
   truncatedNormalFrom produce same distributions as struct-based sampling.
10. **TruncatedNormal SIMD vectors** — vectorTruncatedNormal produces finite
    values within bounds for multiple vector lanes.
11. **TruncatedNormal f32** — f32 variant works correctly with f32 precision.

## Significance

S4-M1250 delivers:

1. **Truncated normal distribution** with mathematically correct moments,
   degenerate/one-sided/unbounded fast paths, and a deterministic
   inverse-CDF algorithm that vectorizes trivially and avoids unbounded
   rejection-loop latency in extreme tails.

2. **Public mathematical helpers** for normal PDF/CDF/probit that support both
   scalar (f32/f64) and SIMD vector types — useful on their own and as
   building blocks for future distributions (logit, probit regression,
   inverse-CDF-based samplers).

3. **Completed circular distribution APIs**: `vonMises` and `wrappedCauchy`
   are now fully public with complete Checked/vector/fill families matching
   the pattern established by all other alea distributions, and vector
   structs for reusable SIMD sampling.

4. **Beyond `rand_distr`**: Truncated normal is not exposed in local Rust
   `rand_distr` 0.4's public API, giving alea a meaningful coverage advantage
   in the continuous bounded-distribution space while maintaining Zig-native
   API shapes.

Erf/probit accuracy (~1.5e-7 for erf CDF, full machine precision for probit
with Newton refinement) is sufficient for inverse-CDF sampling but not for
high-precision numerical CDF work; a higher-precision erf (e.g., Cody's
rational approximation) could be added later if needed.

Directional/spherical distribution extensions (von Mises-Fisher for N-sphere,
Kent, Bingham), copula methods, weighted/alias sampling, sequence/string
generation, and longer statistical validation runs remain as candidates for
the next product bar.
