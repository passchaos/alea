# S4-M1298 — Kent (Fisher-Bingham F5) distribution on S²

## Goal

Add the Kent distribution — the five-parameter Fisher-Bingham F5 distribution
on the unit sphere S² — to complement the existing Von Mises-Fisher, Watson,
and Bingham directional families. The density is

```
f(x) ∝ exp(κ·γ₁ᵀx + β·((γ₂ᵀx)² − (γ₃ᵀx)²)),   x ∈ S²,
```

where `γ₁` is the mean direction, `(γ₁, γ₂, γ₃)` is an orthonormal frame,
`κ ≥ 0` is the concentration, and `0 ≤ β < κ/2` is the ovalness. The
distribution is absent from local Rust `rand` / `rand_distr` core.

## Implementation

### Public API

`Kent(T)` (3D-only, no dimension parameter):

- `init(mean_direction, major_axis, kappa, beta) !Self` — validates `κ ≥ 0`,
  `0 ≤ β < κ/2`, a unit mean direction, and a major axis with a non-zero
  component in the tangent plane; the major axis is projected and normalized,
  and `γ₃ = γ₁ × γ₂`. `new` is the debug-only panicking constructor.
- `meanDirection`, `majorAxis`, `minorAxis`, `concentrationValue`,
  `ovalnessValue`, `dimensionValue`, `modeValue`.
- `meanResultantLength` (`E[γ₁ᵀx]`), `expectedValue` (`E[x] = ρ·γ₁`),
  `varianceValue` (`1 − ρ²`), `covarianceAt(row, col)`, `varianceAt(index)`.
- `sample` / `sampleFrom`, `fill` / `fillFrom`.

Free functions: `kent`, `kentFrom`, `kentChecked`, `kentCheckedFrom`,
`fillKent`, `fillKentFrom`, `fillKentChecked`, `fillKentCheckedFrom`.

`KentError` distinguishes `InvalidParameter` (bad κ/β) from
`InvalidMeanDirection` (bad mean or major axis).

### Sampling

Exact rejection from a Von Mises-Fisher proposal:

1. Compute the target mean resultant length `ρ = E[γ₁ᵀx]` by deterministic
   quadrature and choose the proposal concentration `λ` such that the
   `S²` vMF mean resultant `coth(λ) − 1/λ` equals `ρ`.
2. Bound the joint ratio analytically. With `x = wγ₁ + √(1−w²)(cosφ γ₂ + sinφ γ₃)`,
   the target/proposal ratio is
   `exp((κ−λ)w + β(1−w²)cos(2φ))`, whose supremum is
   `exp(max_w[(κ−λ)w + β(1−w²)])` at `cos(2φ) = 1`.
3. Propose `x ~ vMF(λ, γ₁)`, accept with probability
   `exp((κ−λ)w + β(1−w²)cos(2φ) − max_exponent)`.

Matching the proposal mean to the target keeps acceptance high across the
parameter range, including the near-boundary `2β → κ` regime where a naive
`e^β` envelope collapses. `β = 0` delegates bit-for-bit to
`VonMisesFisher(T, 3)`, `κ = 0` is uniform on S², and `κ > 1e12` is a point
mass at `γ₁`.

### Moments

`E[w]`, `Var[w]`, and the two tangential covariance components are computed
deterministically from the w-marginal
`p(w) ∝ e^{κw} I₀(β(1−w²))`:

- adaptive Simpson quadrature on `[-1, 1]` with Richardson correction,
  tolerance `1e-10` (f64) / `1e-5` (f32);
- a leading-order expansion for `κ > 1e4` with `κ − 2β > 10` to avoid
  resolving an extremely narrow peak.

The covariance in the frame is `diag(Var[w], c₊, c₋)` with
`c± = (E[1−w²] ± E[(1−w²)·I₁(a)/I₀(a)])/2`, `a = β(1−w²)`, so the ovalness
produces the expected γ₂/γ₃ anisotropy.

## Tests added (7 new, total 852)

1. Constructor validation, frame orthonormality, and axis projection.
2. `β = 0` bit-for-bit reduction to `VonMisesFisher(T, 3)`, including the
   mean resultant length.
3. 40,000-sample mean/covariance recovery, unit norms, γ₂/γ₃ anisotropy, and
   the trace identity `Var[x] = 1 − ρ²`.
4. Mean resultant length vs direct 20,000-step numerical integration.
5. Free functions, fills, checked error paths, and direct-source parity.
6. f32 sampling and finite moments.

## Validation

- Focused `zig test src/root.zig --test-filter "Kent"` passes 7/7.
- `zig build test --summary all` passes 852/852 tests; `apicheck`,
  `readmecheck`, `toolingcheck`, `roadmapcheck`, and `examplecheck` are green.
- `docs/api-reference.md` updated for all 29 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1298 row added.

## Next bar

Matrix von Mises-Fisher, vector/SIMD copula/Bingham/Kent sampling, longer
statistical validation runs, or newly discovered core gaps against local Rust
`rand` / `rand_distr` evidence.
