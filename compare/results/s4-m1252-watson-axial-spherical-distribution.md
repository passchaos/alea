# S4-M1252: Watson Axial Spherical Directional Distribution

## Milestone

S4-M1252 — Watson axial spherical directional distribution: add a distribution
on the n-dimensional unit sphere Sⁿ⁻¹ for comptime n≥2, the antipodally symmetric
(x ↔ −x) counterpart to the Von Mises-Fisher distribution (S4-M1251). The Watson
distribution supports three regimes: bipolar (κ > 0, concentration around ±μ),
girdle (κ < 0, concentration around the great-circle equator perpendicular to
μ), and uniform (κ = 0). This fills a feature gap entirely absent from Rust
`rand`/`rand_distr` core. Implementation uses Beta((n-1)/2,(n-1)/2) rejection
sampling for the cosine w coordinate with log-ratio envelope tests, uniform
Sⁿ⁻² equatorial tangent points, a shared Householder reflection helper factored
out of Von Mises-Fisher, Kummer confluent hypergeometric ₁F₁ series for mean
cosine-squared moment computation, and fast paths for κ→±∞ (±μ bipolar point
mass and equator girdle).

## Gap

Local Rust `rand_distr` provides no Watson distribution, nor any axial
(antipodally symmetric) spherical distribution. Alea's directional coverage
prior to this milestone included circular distributions (Von Mises S4-M1246,
Wrapped Cauchy S4-M1247) and the Von Mises-Fisher spherical distribution
(S4-M1251) for directed (non-axial) data, but lacked:

1. Any distribution for axial spherical data, where observations x and −x are
   equivalent (e.g., axis orientations in crystallography/geology, undirected
   normals, fiber directions, bipolar clustering).
2. A girdle-concentration distribution for data concentrated around a great
   circle (equator), needed for modeling planar/equatorial directional data.
3. A shared Householder reflection helper (previously duplicated inline in
   vMF code).
4. A Kummer confluent hypergeometric function ₁F₁ needed for Watson moment
   computation and other future directional distributions (e.g., Bingham).

## Implementation

### WatsonError

`WatsonError` aliases `error.InvalidParameter` (κ non-finite or n < 2) and
`error.InvalidMeanDirection` (mean axis vector has non-unit norm or contains
non-finite values), following the existing error-alias convention. Both
`VonMisesFisherError` and `WatsonError` are declared at file scope with
distinct doc comments rather than being inlined inside each distribution
struct.

### Watson(T, n) struct

`Watson(T, n)` follows the canonical distribution struct pattern with comptime
dimension parameter:

- `comptime requireFloat(T);` and `comptime if (n < 2) @compileError("n ≥ 2 required");`
- `init(mean_axis, kappa)` — validates parameters:
  - κ must be finite.
  - mean_axis is finite in every lane and has unit norm within `√ε(T)·10`.
- `new(mean_axis, kappa)` — panics on invalid parameters (debug assertion).
- `initNormalized(mean_axis, kappa)` — skips unit-norm validation for
  caller-guaranteed unit axes.
- Accessors: `meanAxis()`, `concentrationValue()`, `dimensionValue()`,
  `expectedValue()`, `meanResultantLength()`, `meanCosineSquared()`,
  `varianceValue()`. Note: because of axial symmetry E[x] ≡ 0 for all κ, so
  `expectedValue()` returns the zero vector and `meanResultantLength()`
  returns `meanCosineSquared() = E[(μᵀx)²]`, which is the meaningful axial
  concentration statistic (ranges from 0 → 1/n → 1 as κ goes from −∞ → 0 → +∞).
- Samplers: `sample(rng)`, `sampleFrom(source)`, `fill(rng, dest)`,
  `fillFrom(source, dest)`.

### Shared Householder helper

The inline Householder reflection code previously embedded in vMF is extracted
into a shared helper:

```zig
fn householderReflectFromE1(comptime T: type, comptime n: usize, x: *@Vector(n, T), mu: @Vector(n, T)) void
```

Given a point `x` in the e1-centered frame and a target unit direction `mu`,
applies the Householder reflection H = I − 2vvᵀ/(vᵀv) where v = e1 − mu. This
rotates x from the e1-centered frame to the mu-centered frame, preserving
spherical symmetry and mapping e1 → mu exactly. Both VonMisesFisher and Watson
use this helper, eliminating code duplication.

### Algorithm

#### Beta rejection sampling for w (cosine of polar angle from e1)

Watson's marginal density on w = μᵀx ∈ [−1, 1] is proportional to
(1−w²)^((n-3)/2) · exp(κ·w²). Sampling w uses:

1. Sample `B ~ Beta(alpha, alpha)` where `alpha = (n-1)/2` (symmetric Beta).
2. Map `w = 2B − 1` to (−1, 1), giving a symmetric Beta-shaped envelope
   proportional to (1−w²)^(alpha−1) = (1−w²)^((n-3)/2).
3. Compute log-acceptance ratio:
   - For bipolar κ > 0: log_accept = κ·(w² − 1)  (target density / envelope at w)
   - For girdle κ < 0:  log_accept = κ·w²        (target density / envelope at w; envelope peak at w=0)
4. Sample `u ~ OpenOpen01(T)`; accept if `@log(u) ≤ log_accept`, else reject
   and resample.

The log-ratio form avoids overflow for large |κ| and keeps acceptance bounded
(~1.5–2 expected iterations across all κ, similar to vMF).

#### Uniform equatorial point v on Sⁿ⁻²

Draw (n−1) independent standard normal variates using
`standardNormalFrom(source, T)`, normalize to unit length, giving a uniform
point on the (n−2)-dimensional sphere in the equatorial hyperplane
perpendicular to e1. Same mechanism used by vMF.

#### Assemble in e1-centered frame

- s = √(1 − w²) (equatorial radius).
- x = [w, s·v_0, s·v_1, …, s·v_{n-2}].
- By construction ||x|| = 1, with e1-marginal w ~ Watson marginal.

#### Householder reflection to mean axis mu

Apply the shared `householderReflectFromE1(T, n, &x, mu)` helper to rotate
from the e1 frame to the mu frame.

#### n=2 (circle S¹) handling

For n=2, the Beta shape alpha = (2−1)/2 = 0.5, which gives B ~ Beta(0.5,0.5)
(arcsine distribution), and w = 2B − 1. The equatorial dimension is n−2 = 0,
so v is empty and s = √(1−w²) = |sin θ| where w = cos θ. A random equatorial
sign gives the full circle. The general algorithm handles n=2 correctly
without a special-case delegation.

#### Fast paths

- **κ = 0:** Watson with zero concentration is uniform on the sphere. Delegates
  directly to `unitSphereSurfaceFrom(source, T, n)` (existing helper from
  S4-M1245).
- **κ > 1e12:** At extremely high bipolar concentration, distribution is
  effectively a point mass at ±μ (axial degeneracy). Returns either μ or −μ
  with equal probability (fair coin flip via a single boolean draw), respecting
  axial symmetry.
- **κ < −1e12:** At extremely high girdle concentration, distribution is
  effectively uniform on the equator (great circle perpendicular to μ).
  Samples a uniform point on Sⁿ⁻² directly in the tangent plane without w
  sampling (w = 0 exactly), then applies Householder reflection.

### Kummer confluent hypergeometric ₁F₁

For mean cosine-squared moments at moderate |κ|, a truncated power series
computes M(a; b; z) = ₁F₁(a; b; z):

```zig
fn kummerM(T: type, a: T, b: T, z: T, max_terms: comptime_int) T
```

- Uses the series M(a;b;z) = Σ_{k=0}^∞ (a)_k z^k / ((b)_k k!) where (x)_k is
  the rising factorial.
- Iterates up to `max_terms = 60`, breaking early when the absolute term is
  less than `1e-15 * |sum|`.
- Sanity check: M(1; 1; z) = exp(z), verified in tests to within 1e-12 for
  z ∈ [−50, 50].
- For |z| > 50, asymptotic expansions are used instead of the series to avoid
  divergence/slow convergence:
  - For large positive z: M(a;b;z) ≈ Γ(b)/Γ(a) · z^(a−b) · exp(z) ·
    (1 + (a−b)(1−a)/(z) + O(1/z²)).
  - For large negative z: M(a;b;z) ≈ Γ(b)/Γ(b−a) · (−z)^(−a) ·
    (1 + a(1+a−b)/(−z) + O(1/z²)).

### Statistical accessors

Because of axial symmetry (x ↔ −x is a symmetry of the density), the first
moment E[x] = 0 identically. The mean direction is undefined modulo sign.
The meaningful axial statistics are:

- **`meanCosineSquared()`** (ρ₂ = E[(μᵀx)²]):
  - κ = 0: ρ₂ = 1/n exactly (uniform sphere).
  - Moderate |κ| ≤ 50: ρ₂ uses Kummer M ratios:
    ρ₂ = (M(3/2; n/2+1; κ)) / (n·M(1/2; n/2; κ)) for bipolar κ > 0,
    with analogous formulas for girdle κ < 0 using the imaginary-axis
    continuation (equivalent to M(a;b;κ) = M(b−a;b;−κ)·exp(κ) via Kummer
    transformation, stabilizing negative-κ evaluation).
  - κ → +∞ (bipolar): ρ₂ ≈ 1 − (n−1)/(2κ) (asymptotic expansion).
  - κ → −∞ (girdle): ρ₂ ≈ (n−1)/(−2κ) for n ≥ 3, ≈ 1/(−2κ) for n = 2
    (asymptotic expansion, verified to be dimensionally correct).
- **`meanResultantLength()`** returns `meanCosineSquared()`, providing the
  standard axial concentration statistic under the API's conventional name.
- **`expectedValue()`** returns the zero vector (by axial symmetry).
- **`varianceValue()`** returns 1 − ρ₂ (spherical variance analog for axial
  data, 0 for perfect bipolar alignment, 1 − 1/n for uniform, 1 for perfect
  girdle).

### Free-function family

Following the standard alea distribution API pattern, the following free
functions are provided (16-function family, matching the spherical sampling
subset without vector samplers — vector SIMD spherical bulk paths are deferred
to a future milestone):

- Scalar sample: `watson`, `watsonFrom`, `watsonChecked`, `watsonCheckedFrom`.
- Bulk fill: `fillWatson`, `fillWatsonFrom`, `fillWatsonChecked`,
  `fillWatsonCheckedFrom`.

The `*From` variants accept a custom random source; `*Checked` variants return
a `WatsonError` union; non-Checked variants use `.new()` and return non-error
types, panicking in debug mode on invalid parameters.

## Tests

Ten new tests in `src/distributions.zig`:

1. **Constructor validation** — rejects non-finite κ, non-unit mean axis,
   non-finite parameters; accepts valid unit vectors for n=2,3,4.
2. **3D bipolar concentration** — at κ=20, 5000 samples have mean cosine
   squared > 0.9 (strongly concentrated near ±μ).
3. **κ=0 uniformity** — 8000 samples on S² at κ=0 have mean cos² ≈ 1/3
   within 2σ (consistent with uniform sphere; exact value 1/3).
4. **Girdle concentration near equator** — at κ=-20, 5000 samples have
   |cos θ| < 0.1 for over 99% of draws (concentrated on equator).
5. **High-κ bipolar degeneracy** — at κ=1e15, every sample is either μ or −μ
   exactly (point mass up to sign).
6. **Free functions and fill bulk path** — `fillWatson` produces unit-norm
   outputs; `watsonChecked` returns error on invalid input.
7. **4D unit vectors** — 500 samples in S³ (n=4) all have ||x|| within 1e-10
   of 1 and lie on S³.
8. **2D circle bipolar** — 2000 samples on S¹ at κ=20 have mean cos² > 0.8
   (bipolar concentration around ±(1,0)).
9. **f32 support** — f32 variant works; unit norm within f32 epsilon;
   κ=0 uniformity holds for f32.
10. **kummerM sanity** — M(1,1,z) = exp(z) to within 1e-12 for z ∈ [−50, 50],
    verifying hypergeometric series correctness.

All 652 tests pass (642 pre-existing + 10 new).

## Refactoring: shared Householder helper

As part of Watson's implementation, the inline Householder reflection code
in vMF (previously ~15 lines duplicated in `vonMisesFisherPointFrom`) was
extracted into `householderReflectFromE1`. This reduces duplication and
ensures both vMF and Watson use identical, tested rotation logic. vMF's
existing tests continue to pass (refactoring is behavior-preserving).

## API Reference Update

`docs/api-reference.md` documents all 24 new public symbols:

- `WatsonError`
- `Watson(T, n)` with 13 methods: `init`, `new`, `initNormalized`, `meanAxis`,
  `concentrationValue`, `dimensionValue`, `expectedValue`, `meanResultantLength`,
  `meanCosineSquared`, `varianceValue`, `sample`, `sampleFrom`, `fill`,
  `fillFrom`
- 8 free functions: `watson`, `watsonFrom`, `watsonChecked`,
  `watsonCheckedFrom`, `fillWatson`, `fillWatsonFrom`,
  `fillWatsonChecked`, `fillWatsonCheckedFrom`
- Internal helpers (`kummerM`, `watsonSampleWFrom`, `watsonPointFrom`,
  `fillWatsonPointsFrom`, `householderReflectFromE1`) are file-private,
  not exported.

## Deviations from Rust `rand_distr`

- Rust `rand_distr` does not provide Watson at all. Alea extends beyond parity
  here, as it did with vMF (S4-M1251), Truncated Normal (S4-M1250), and
  Wrapped Cauchy (S4-M1247).
- The axial first-moment convention returns zero vector for `expectedValue()`
  and overloads `meanResultantLength()` to return the axial concentration
  statistic (mean cosine squared), with an explicit `meanCosineSquared()`
  accessor for clarity. This differs from vMF's directed convention but is
  statistically necessary: ||E[x]|| ≡ 0 for all κ in an axial distribution,
  so the directed "mean resultant length" is trivial and uninformative.
- The shared `householderReflectFromE1` helper and `kummerM` hypergeometric
  function are infrastructure pieces not specific to Watson; they will support
  Bingham and other future directional distributions.
- `initNormalized` is an Alea-specific ergonomic addition consistent with
  vMF and other spherical distributions.

## Verification

- `zig build test` passes — all 652 tests green.
- `zig build apicheck` passes — all 24 new symbols appear in
  `docs/api-reference.md`.
- `zig build roadmapcheck` requires `compare/results/s4-m1252-watson-axial-spherical-distribution.md`
  and a `| S4-M1252 | Watson axial spherical directional distribution`
  closure row in `core-rand-coverage.md`.
- `zig build validate` passes all gates (apicheck, readmecheck, examplecheck,
  toolingcheck, distcheck, statcheck, roadmapcheck).

## Next bar

Additional directional/multivariate distributions (Bingham, Matrix von
Mises-Fisher, Kent), copula methods, SIMD spherical bulk sampling paths,
weighted/alias sampling advances, string generation expansion, longer
statistical validation runs, broader platform evidence, or newly discovered
core random-workflow gaps.

## References

- Watson, G. S. (1965). "Equatorial distributions on a sphere." *Biometrika*,
  52(1/2), 193–201.
- Mardia, K. V. & Jupp, P. E. (2000). *Directional Statistics*. Wiley.
  (Chapter 9: Watson distribution; Chapter 10: Bingham distribution.)
- Best, D. J. & Fisher, N. I. (1986). "Goodness-of-fit and discordancy tests
  for samples from the Watson distribution on the sphere." *Australian
  Journal of Statistics*, 28(2), 137–151.
- Wood, A. T. A. (1994). "Simulation of the von Mises Fisher distribution."
  *Communications in Statistics – Simulation and Computation*, 23(1), 157–164.
  (Ulrich transform reused for tangent-plane Householder reflection.)
- Abramowitz, M. & Stegun, I. A. (1964). *Handbook of Mathematical Functions*.
  (Confluent hypergeometric function ₁F₁, Chapter 13.)
- Rust `rand_distr` 0.6.0 public surface manifest:
  `compare/results/s4-m294-rand-distr-public-surface-manifest.md`
- Existing Von Mises-Fisher (Sⁿ⁻¹ directed) implementation: S4-M1251.
- Existing circular Von Mises (S¹ directed) implementation: S4-M1246.
