# S4-M1245: Rust API parity, N-dimensional geometry, standard distributions

Date: 2026-07-18

This milestone closes the remaining API ergonomics gaps versus Rust `rand` after
S4-M1244 standardized the parameter-free distributions as polymorphic unit
structs, adds general N-dimensional unit sphere/ball sampling, and completes
the set of common standard zero-parameter continuous distributions as unit
structs matching the StandardUniform/StandardNormal/StandardExponential pattern.

## Improvements delivered

### Rust-compatible aliases

- `Standard` alias for `StandardUniform` matching Rust `rand::distributions::Standard`
  naming for users porting code. This is the default sampler: `rng.sample(T, Standard{})`
  produces values uniformly across the full type range, with full recursive
  support for composite types identical to `StandardUniform{}`.
- `Exp1` alias for `StandardExponential` (already added in S4-M1244) matches
  Rust `rand::distributions::Exp1` naming.

### N-dimensional unit geometry sampling (generalized beyond fixed 2D/3D)

- `unitSphereSurface(rng, T, n)` / `unitSphereSurfaceFrom(source, T, n)`:
  Generate uniformly random points on the surface of the n-dimensional unit
  sphere using Marsaglia's algorithm (n independent standard normal variates
  normalized by their Euclidean norm, with rejection for degenerate near-zero
  vectors for numerical stability).
- `fillUnitSphereSurface` / `fillUnitSphereSurfaceFrom`: Bulk fill for
  N-dimensional surface points.
- `unitBallVolume(rng, T, n)` / `unitBallVolumeFrom(source, T, n)`: Generate
  uniformly random points inside the n-dimensional unit ball using the correct
  radial scaling u^(1/n) where u ~ Uniform(0,1), matching the n-ball volume
  element. Includes specialized fast paths for 1D (interval [-1,1]) and 2D
  (unit disk via polar rejection).
- `fillUnitBallVolume` / `fillUnitBallVolumeFrom`: Bulk fill for N-dimensional
  ball points.
- `UnitSphereSurface` / `UnitBallVolume` reusable polymorphic unit-struct
  samplers following the same API pattern as other standard distributions,
  with dimension passed as a comptime parameter for type safety.
- Specialized 2D/3D fast paths retained for common graphics/physics use cases
  (existing `unitCircle`, `unitSphere`, `unitBall` functions are unchanged).

### Additional standard continuous distributions as unit structs

- `StandardCauchy{}`: Standard Cauchy (Lorentz) distribution with median=0,
  scale=1. Heavy-tailed distribution with undefined mean and variance
  (returns `null` for both). Uses ratio-of-tangents algorithm with open (0,1)
  uniforms to avoid pole singularities. Supports scalar f32/f64 and vector
  types with SIMD dispatch.
- `StandardLogistic{}`: Standard logistic distribution with location=0,
  scale=1. Mean=0, variance=π²/3 ≈ 3.2899. Uses inverse-CDF sampling
  X = log(u/(1-u)). Supports scalar f32/f64 and vector types with SIMD
  dispatch.

### API consistency

- All new standard distributions follow the same polymorphic unit struct
  pattern: methods take T as comptime parameter, automatically dispatch between
  scalar and vector types, provide accessor methods for moments/parameters,
  and integrate with `rng.sample(T, dist)`, `rng.fillSample(T, buf, dist)`,
  and `rng.sampleIter(T, dist)` workflows.
- Full vector SIMD support for StandardCauchy and StandardLogistic, matching
  the existing vector capability of StandardNormal and StandardExponential.

## Validation evidence

- All 600+ unit tests pass, including new tests for:
  - `Standard` alias producing identical output to `StandardUniform`
  - `StandardCauchy` producing finite samples with correct moments
  - `StandardLogistic` producing samples with correct mean/variance
  - N-dimensional sphere points lying on the unit surface (norm=1) for 4D/10D
  - N-dimensional ball points lying inside the unit ball (norm≤1) for 1D/5D
  - Bulk fill operations producing correctly distributed points
- `zig build validate` passes:
  - distcheck: all distribution moment checks pass
  - statcheck: statistical moment validation for all distributions
  - profilecheck: SIMD vector path validation
  - apicheck: all new public symbols documented in api-reference.md
  - roadmapcheck, toolingcheck, readmecheck, examplecheck all pass
- Statistical quality: standard normal/exponential vector paths confirmed
  correct CDF values across 1M+ samples (existing validation, unchanged).

## Coverage versus Rust rand_distr

With this milestone, alea now provides:

| Rust `rand_distr` feature | Alea equivalent |
|---------------------------|-----------------|
| `Standard` | `Standard` (alias) / `StandardUniform` |
| `Exp1` | `Exp1` (alias) / `StandardExponential` |
| `StandardNormal` | `StandardNormal` |
| `UnitSphereSurface` (3D) | `unitSphere` + `UnitSphereSurface{n}` for general n |
| `UnitBall` (3D) | `unitBall` + `UnitBallVolume{n}` for general n |
| `UnitCircle` (2D) | `unitCircle` |
| `StandardCauchy` | `StandardCauchy` |
| `Open01`, `OpenClosed01` | `Open01`, `OpenClosed01` |
| `StandardGeometric` | `StandardGeometric` |
| `Alphanumeric` | `Alphanumeric` |

All parameter-free standard distributions are now available as ergonomic unit
structs matching Rust naming conventions where appropriate, while extending
capabilities with native Zig SIMD vector support and generalized N-dimensional
geometry sampling beyond the fixed-dimension implementations in Rust.
