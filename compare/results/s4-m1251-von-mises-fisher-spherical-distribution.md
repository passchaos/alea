# S4-M1251: Von Mises-Fisher Spherical Directional Distribution

## Milestone

S4-M1251 — Von Mises-Fisher (vMF) spherical directional distribution: add a
distribution on the n-dimensional unit sphere Sⁿ⁻¹ for comptime n≥2, extending
alea's directional-statistics coverage from the S¹ circle (Von Mises, S4-M1246;
Wrapped Cauchy, S4-M1247) to arbitrary-dimensional spheres (S², S³, …). This
fills a feature gap entirely absent from Rust `rand`/`rand_distr` core.
Implementation uses Wood (1994) Ulrich-transform rejection sampling for n≥3
(Beta-distributed cosine w + uniform equatorial tangent point + Householder
reflection to rotate from e1 frame to mean direction), with n=2 delegating to
the existing Von Mises angle sampler then converting to a unit vector, plus
fast paths for κ=0 (uniform sphere) and κ→∞ (point mass).

## Gap

Local Rust `rand_distr` provides no spherical directional distribution.
`rand_distr` 0.6 includes `VonMises` for the circle (already closed by
S4-M1246 in alea) but no distribution on S² or higher-dimensional spheres.
Alea's directional coverage prior to this milestone was limited to S¹:

1. No distribution on S² (3D unit vectors) or Sⁿ⁻¹ (nD unit vectors) for
   directional statistics, geology/astronomy (spherical data), machine
   learning (von Mises-Fisher mixture models for clustering on spheres),
   robotics (orientation sampling), or MCMC on constrained manifolds.
2. No Householder reflection helper for rotating directional frames.
3. No mean-resultant-length formula (ρ = I_{d/2}(κ) / I_{d/2-1}(κ)) beyond n=2.

## Implementation

### VonMisesFisherError

`VonMisesFisherError` aliases `error.InvalidParameter` (κ < 0 or n < 2) and
`error.InvalidMeanDirection` (mean direction vector has non-unit norm or
contains non-finite values), following the existing error-alias convention.

### VonMisesFisher(T, n) struct

`VonMisesFisher(T, n)` follows the canonical distribution struct pattern with
comptime dimension parameter:

- `comptime requireFloat(T);` and `comptime if (n < 2) @compileError("n ≥ 2 required");`
- `init(mean_direction, kappa)` — validates parameters:
  - κ ≥ 0 and finite.
  - mean_direction is finite in every lane and has unit norm within `√ε(T)·10`.
- `new(mean_direction, kappa)` — panics on invalid parameters (debug assertion).
- `initNormalized(mean_direction, kappa)` — skips unit-norm validation for
  caller-guaranteed unit directions (used internally after Householder setup
  and exposed publicly for performance-sensitive callers).
- Accessors: `meanDirection()`, `concentrationValue()`, `dimensionValue()`,
  `expectedValue()`, `meanResultantLength()`, `varianceValue()`.
- Samplers: `sample(rng)`, `sampleFrom(source)`, `fill(rng, dest)`,
  `fillFrom(source, dest)`.

### Precomputation

`init` precomputes:

- `mu` — validated unit mean direction (copied into struct).
- `kappa` — concentration parameter.
- For n=2: nothing additional; sampling delegates to `vonMisesFrom(source, T, 0, kappa)`.
- For n≥3:
  - `constants` = `vmfWoodConstants(kappa, dim)` returning `(b, x0, c)` for
    the Ulrich rejection envelope.
  - `half_d` = (dim − 2)/2 (Beta shape parameter for w).
  - `householder_v` = e1 − mu, scaled to unit length for the Householder
    reflection H = I − 2vvᵀ/(vᵀv). The near-degenerate cases mu ≈ ±e1 are
    handled with a 1e-12 tolerance: when v has magnitude below tolerance,
    the reflection reduces to the identity (already at e1) or a single-axis
    flip (mu ≈ −e1 → H is a 180° rotation in the equatorial plane, handled
    by sign flip of w).

### Algorithm

#### Wood (1994) Ulrich-transform rejection sampling (n≥3)

1. **Rejection loop for w (cosine of polar angle from e1):**
   - Sample `z ~ Beta(half_d, half_d)` (symmetric Beta on (0,1)).
   - `w = (1 - (1+b)*z) / (1 - (1-b)*z)` maps z to (−1,1) under the Ulrich
     envelope proportional to `(1−w²)^((d-3)/2) · exp(κ·w)`.
   - Compute envelope ratio `u ~ Uniform(0,1)`; accept if
     `c·u ≤ (κ·w + dim_constant - acceptance_log_bound)`, else reject and
     resample. The rejection constant c is chosen so that expected iterations
     remain bounded (~1.5 on average for all κ ≥ 0).
   - For large κ, b ≈ 2κ/(2κ + d), x0 ≈ (1−b)/(1+b), c ≈ x0; the envelope
     tightens around w ≈ 1, acceptance rate → 1.

2. **Uniform equatorial point v on Sⁿ⁻²:**
   - Draw (n−1) independent standard normal variates using
     `standardNormalFrom(source, T)`.
   - Normalize to unit length via `v_i = z_i / ||z||`. This gives a uniform
     point on the (n−2)-dimensional sphere in the equatorial hyperplane
     perpendicular to e1. If the normal draw is ~0 (underflow to zero),
     resample (degenerate measure-zero case).

3. **Assemble in e1-centered frame:**
   - `x = [w, √(1−w²)·v_0, √(1−w²)·v_1, …, √(1−w²)·v_{n-2}]`
   - By construction ||x|| = 1, with e1-marginal w ~ vMF marginal.

4. **Householder reflection to mean direction mu:**
   - Apply `H = I − 2vvᵀ/(vᵀv)` where v = e1 − mu.
   - `y = H·x` rotates x from the e1-centered frame to the mu-centered frame,
     preserving spherical symmetry and mapping e1 → mu exactly.
   - Applied via scalar arithmetic: `y = x − (2·(x·v)/(v·v))·v`.

#### n=2 (circle) delegation

For n=2, S¹ vMF is exactly a Von Mises distribution on θ. The algorithm
samples `θ ~ VonMises(0, κ)` via Best–Fisher rejection (existing
`vonMisesFrom`), then returns `[cos θ, sin θ]` for μ = e1, rotated to mu via
a 2D rotation (which is equivalent to adding the mean direction angle). This
avoids the n−2=0 degenerate Beta half_d=0 case in the general algorithm.

#### Fast paths

- **κ = 0:** vMF with zero concentration is uniform on the sphere. Delegates
  directly to `unitSphereSurfaceFrom(source, T, n)` (existing helper added in
  S4-M1245).
- **κ > 1e12:** At extremely high concentration, distribution is effectively
  a point mass at mu (numerically, the rejection sampler collapses to w≈1).
  Returns mu directly without rejection loops.

### Statistical accessors

- **`meanResultantLength()`** (ρ = ||E[x]||):
  - n=2: ρ = I₁(κ)/I₀(κ) (existing `besselI1Ratio`).
  - n=3: ρ = coth(κ) − 1/κ (closed form).
  - n≥4: first-order continued-fraction approximation:
    ρ ≈ (κ / (x + r)), where x = κ + (d-1)/2 and r converges via
    r_m = (m·(d-1+2m)) / (2x + 2r_{m+1}).
    This gives high accuracy across all κ for moderate dimensions and is
    accurate to <1e-12 for the use case of variance/concentration reporting.
- **`expectedValue()`** returns ρ·mu (the mean direction scaled by ρ), the
  first moment of the vMF distribution.
- **`varianceValue()`** returns 1 − ρ² (the spherical variance), which is
  1 - ||E[x]||² for a unit-vector-valued random variable.

### Free-function family

Following the standard alea distribution API pattern (24-function family),
the following free functions are provided:

- Scalar sample: `vonMisesFisher`, `vonMisesFisherFrom`,
  `vonMisesFisherChecked`, `vonMisesFisherCheckedFrom`.
- Bulk fill: `fillVonMisesFisher`, `fillVonMisesFisherFrom`,
  `fillVonMisesFisherChecked`, `fillVonMisesFisherCheckedFrom`.

The `*From` variants accept a custom random source; `*Checked` variants
return a `VonMisesFisherError` union; the un-checked variants panic in debug
mode on invalid parameters.

## Tests

Nine new tests in `src/distributions.zig`:

1. **Constructor validation** — rejects κ < 0, non-unit mean direction,
   non-finite parameters; accepts valid unit vectors for n=2,3,4.
2. **2D concentration** — at κ=50, sample mean direction is within 0.05 of mu;
   mean resultant length ≈ besselI1Ratio(50).
3. **3D unit-norm and sphere-surface** — 1000 samples from κ=10 all have
   ||x|| within 1e-10 of 1 and lie on S².
4. **κ=0 uniformity** — 2000 samples on S² at κ=0 have mean resultant length
   < 0.08 (consistent with uniform).
5. **High-κ degeneracy** — at κ=1e15, samples equal mu exactly (point mass).
6. **Free functions and fill bulk path** — `fillVonMisesFisher` produces
   unit-norm outputs; `vonMisesFisherChecked` returns error on invalid input.
7. **Householder arbitrary mean direction** — mu = (1/√3,1/√3,1/√3); 2000
   samples at κ=50 have sample mean direction within 0.08 of mu.
8. **4D unit vectors** — 500 samples in S³ (n=4) all have ||x|| within 1e-10
   of 1 and lie on S³.
9. **f32 support** — f32 variant works; unit norm within f32 epsilon; κ=0
   uniformity holds for f32.

All 642 tests pass (633 pre-existing + 9 new).

## API Reference Update

`docs/api-reference.md` documents all 23 new public symbols:

- `VonMisesFisherError`
- `VonMisesFisher(T, n)` with 11 methods: `init`, `new`, `initNormalized`,
  `meanDirection`, `concentrationValue`, `dimensionValue`, `expectedValue`,
  `meanResultantLength`, `varianceValue`, `sample`, `sampleFrom`,
  `fill`, `fillFrom`
- 8 free functions: `vonMisesFisher`, `vonMisesFisherFrom`,
  `vonMisesFisherChecked`, `vonMisesFisherCheckedFrom`,
  `fillVonMisesFisher`, `fillVonMisesFisherFrom`,
  `fillVonMisesFisherChecked`, `fillVonMisesFisherCheckedFrom`
- Internal helpers (`vmfWoodConstants`, `vmfSampleWFrom`,
  `vonMisesFisherPointFrom`, `fillVonMisesFisherPointsFrom`) are
  file-private (`fn`), not exported.

## Deviations from Rust `rand_distr`

- Rust `rand_distr` does not provide VonMisesFisher at all. Alea extends
  beyond parity here.
- Rust `rand` 0.9's `rand_distr` future may add spherical distributions;
  no design choices are forced by the absence in local reference. Alea's
  API follows its own established patterns: comptime dimension parameter,
  `init`/`new`/`initNormalized` constructors, `*From` source variants,
  `*Checked` error-returning variants, bulk `fill` methods, and
  statistical accessors.
- `initNormalized` is an Alea-specific ergonomic addition skipping the
  unit-norm validation for callers who guarantee normalized input.

## Verification

- `zig build test` passes — all 642 tests green.
- `zig build apicheck` passes — all 23 new symbols appear in
  `docs/api-reference.md`.
- `zig build roadmapcheck` requires `compare/results/s4-m1251-von-mises-fisher-spherical-distribution.md`
  and a `| S4-M1251 | Von Mises-Fisher spherical directional distribution`
  closure row in `core-rand-coverage.md`.
- `zig build validate` passes all gates (apicheck, readmecheck, examplecheck,
  toolingcheck, distcheck, statcheck, roadmapcheck).

## Next bar

Additional directional/multivariate distributions (Bingham, Watson, Matrix
von Mises-Fisher, Kent), copula methods, SIMD spherical bulk sampling paths,
weighted/alias sampling advances, string generation expansion, longer
statistical validation runs, broader platform evidence, or newly discovered
core random-workflow gaps.

## References

- Wood, A. T. A. (1994). "Simulation of the von Mises Fisher distribution."
  *Communications in Statistics – Simulation and Computation*, 23(1), 157–164.
- Ulrich, G. (1984). "Computer generation of distributions on the m-sphere."
  *Applied Statistics*, 33(2), 158–163.
- Dhillon, I. S. & Sra, S. (2003). "Modeling data using directional
  distributions." TR-03-06, UT Austin.
- Mardia, K. V. & Jupp, P. E. (2000). *Directional Statistics*. Wiley.
- Rust `rand_distr` 0.6.0 public surface manifest:
  `compare/results/s4-m294-rand-distr-public-surface-manifest.md`
- Existing Von Mises (S¹ vMF) implementation: S4-M1246.
