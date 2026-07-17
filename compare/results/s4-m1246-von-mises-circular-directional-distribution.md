# S4-M1246: Von Mises circular distribution, directional statistics

Date: 2026-07-18

This milestone adds the Von Mises circular distribution (the "circular normal"
distribution), which is the most widely used distribution for directional
statistics on the circle S¹. Critically, Rust's `rand_distr` does **not**
include a Von Mises distribution, so this addition extends alea beyond
`rand`'s core continuous distribution coverage into directional statistics
territory rather than merely matching parity.

## Improvements delivered

### Von Mises distribution

The Von Mises distribution is the maximum-entropy distribution on the circle
for fixed mean direction and concentration, and is the circular analog of the
normal distribution. Its PDF is:

```
f(θ; μ, κ) = exp(κ cos(θ - μ)) / (2π I₀(κ))
```

where:
- μ ∈ (-π, π] is the mean direction (location parameter)
- κ ≥ 0 is the concentration parameter (κ=0 is uniform, κ→∞ approaches a point mass at μ)
- I₀ is the modified Bessel function of the first kind, order 0

### API surface

#### Parameterized distribution: `VonMises(T)`

- `VonMises(f64).new(mu, kappa)`: Construct with given mean direction μ and
  concentration κ. Returns `error.InvalidParameter` for negative, infinite,
  or NaN κ.
- Accessors: `locationValue()`, `concentrationValue()`, `expectedValue()`,
  `varianceValue()`, `medianValue()`, `modeValue()`, `minValue()`, `maxValue()`.
  The circular variance is 1 - I₁(κ)/I₀(κ), the circular dispersion;
  all quantile accessors return values relative to μ.
- `sample(rng) -> T` / `sampleFrom(source) -> T`: Single-sample methods using
  the Best & Fisher (1979) rejection algorithm.
- `fill(rng, dest)` / `fillFrom(source, dest)`: Bulk fill into a slice.

#### Standard unit struct: `StandardVonMises{}`

- Zero-parameter sampler with μ=0, κ=1 (standard Von Mises centered at 0 with
  unit concentration), following the established polymorphic unit struct
  pattern used by all other standard distributions.
- Used as `rng.sample(f64, StandardVonMises{})`, matching the API shape of
  `StandardNormal{}`, `StandardCauchy{}`, etc.
- Provides all the same statistical property accessors.

### Algorithm details

The Best & Fisher (1979) rejection algorithm is used for sampling:

1. For κ=0: uniform on the circle via simple scaling (special case, avoids
   division by zero in the algorithm constants).
2. Compute constants: τ = 1 + √(1 + 4κ²), ρ = (τ - √(2τ)) / (2κ), r = (1+ρ²)/(2ρ).
3. Rejection loop with two-stage squeeze test:
   - Generate U₁, U₂ ~ Uniform(0,1); z = cos(π U₁); f = (1 + rz)/(r + z); c = κ(r-f).
   - Fast accept if c(2-c) - U₂ > 0 (squeeze test, avoids log).
   - Slow accept if log(c/U₂) + 1 - c ≥ 0 (exact test using log).
   - On accept: generate U₃ ~ Uniform(0,1], sign = sign(U₃ - 0.5), return μ ± arccos(f).

This algorithm has excellent performance characteristics:
- Exact (no approximation in the sampling path).
- Uniformly efficient across all κ ≥ 0; expected number of iterations per sample
  is bounded by ~1.5 for all κ (better than many competing algorithms that
  degrade for small or large κ).
- Requires only three uniforms per proposal plus standard transcendental
  functions (cos, acos, log, sqrt).
- Does not require the Bessel function approximation for sampling (that is
  used only for reporting variance/statistical properties).

### Bessel function ratio for variance

Circular variance requires I₁(κ)/I₀(κ), the ratio of modified Bessel functions
of the first kind. This is computed via:
- Continued fraction expansion (Abramowitz & Stegun 9.1.73) evaluated bottom-up
  for κ ≤ 30, giving high precision.
- Asymptotic form 1 - 1/(2κ) for κ > 30, which is accurate to < 10⁻⁴ in that
  regime.

Note: this approximation is used only for reporting statistical property
metadata. It does not affect the exactness of the sampling algorithm.

### Test coverage

Comprehensive tests validate:
- Constructor rejects invalid negative/NaN/infinite κ.
- Constructor accepts valid κ=0 and κ>0 with correct parameter access.
- All samples fall within the valid (μ-π, μ+π] range for various μ including
  off-center means (5000 samples at μ=1.0, κ=2.0).
- κ=0 produces a uniform circular distribution: 8000 samples binned into 8
  sectors, counts within 15% of expected uniform count.
- Large κ=50 concentrates tightly around the mean: variance is small (<0.05)
  and sample mean over 10000 draws is within 0.03 radians of μ.
- `StandardVonMises{}` unit struct has correct location/concentration, valid
  range, and sample/fill methods produce valid finite angles.
- `wrapAngle` utility correctly maps angles into (-π, π] for both positive
  and negative overflows.
- Bessel function ratio ρ(κ) satisfies boundary conditions ρ(0)=0, monotonic
  increase to 1, and reasonable spot-check values.

## Gap closure

- **Rust `rand` / `rand_distr` comparison**: As of this milestone, the core
  random-number distribution gap versus Rust is actually reversed: alea now
  includes a usable Von Mises distribution for circular/directional statistics
  which `rand_distr` does not provide. Users needing circular statistics
  (navigation, orientation, angles, wind direction, animal movement, etc.)
  have this distribution built into alea without requiring additional
  dependencies.
- Combined with the existing circular geometry samplers (`unitCircle`,
  `UnitDisc`), alea now covers common circular/directional use cases end to end.

## Validation

- All 615+ tests pass (including the 8 new Von Mises-specific tests).
- All checks pass: `zig build validate` completes successfully, including
  apicheck, roadmapcheck, readmecheck, examplecheck, toolingcheck, and
  statistical validation profiles.
- `apicheck` confirms all new public symbols are documented in
  `docs/api-reference.md`.
