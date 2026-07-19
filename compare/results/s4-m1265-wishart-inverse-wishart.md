# S4-M1265: Stack-allocated Wishart and Inverse-Wishart distributions

**Date:** 2026-07-19
**Milestone:** S4-M1265
**Gate:** `zig build validate` passes; 748/748 tests pass; all API surface documented; apicheck passes.

## Summary

Added stack-allocated Wishart and Inverse-Wishart multivariate distributions, extending alea's Bayesian statistics coverage beyond Rust `rand`/`rand_distr` (which lacks both distributions entirely):

- **Wishart W_p(Ψ, ν):** Distribution over p×p symmetric positive-definite matrices, the conjugate prior for the precision matrix (inverse covariance) of a multivariate normal distribution.
- **Inverse-Wishart IW_p(Ψ, ν):** Distribution over p×p symmetric positive-definite matrices, the conjugate prior for the covariance matrix of a multivariate normal distribution.

Both distributions use the existing stack-allocated `Static*` pattern (matching `StaticMultivariateNormal`), requiring no heap allocator when the dimension is known at compile time.

## Design Decisions

### Algorithm: Bartlett decomposition (rejection-free exact sampling)

The Wishart distribution uses the exact, rejection-free Bartlett decomposition algorithm, which composes existing alea primitives:

1. Compute L = lower-triangular Cholesky decomposition of the scale matrix Ψ (reusing the existing Cholesky factorizer from multivariate normal sampling).
2. Construct lower-triangular matrix A:
   - Off-diagonal entries A[i][j] (i > j): independent standard normal draws N(0,1)
   - Diagonal entries A[i][i]: sqrt(χ²(ν − i)) for 0-indexed i (chi-squared draws with ν−i degrees of freedom)
3. Compute X = L A Aᵀ Lᵀ: X ~ W_p(Ψ, ν) exactly.

The Inverse-Wishart distribution samples by:
1. Inverting the scale matrix Ψ to get Ψ⁻¹ via Cholesky inversion.
2. Drawing W ~ W_p(Ψ⁻¹, ν).
3. Inverting W via Cholesky inversion to get X = W⁻¹ ~ IW_p(Ψ, ν).

This approach:
- Is entirely rejection-free (deterministic latency per sample).
- Composes only existing verified primitives (Cholesky, chi-squared, standard normal).
- Requires only O(p³) operations for the matrix multiplies and Cholesky operations, which is optimal for these distributions.

### Cholesky inversion helper

A new `choleskyInvertMatrix(comptime T, comptime dim, L: [dim][dim]T) [dim][dim]T` helper computes the inverse of a symmetric positive-definite matrix given its lower-triangular Cholesky factor:
1. Invert L via forward substitution to get L⁻¹ (lower triangular).
2. Compute X⁻¹ = (L⁻¹)ᵀ L⁻¹: the inverse is the product of the transposed inverse factor with itself.
This is more numerically stable than general matrix inversion and reuses the Cholesky factor already computed for sampling.

### Parameter validation

- `degrees of freedom ν ≥ dim` (p): enforced; otherwise the distribution is not positive-definite.
- Scale matrix Ψ must be symmetric positive-definite: verified during Cholesky factorization; returns `error.NonPositiveDefinite` if not.

### Moments

**Wishart:**
- Expected value: E[X] = ν Ψ
- Mode: mode[X] = (ν − p − 1) Ψ, for ν > p + 1; returns null when ν ≤ p+1 (mode does not exist or boundary).

**Inverse-Wishart:**
- Expected value: E[X] = Ψ / (ν − p − 1), for ν > p + 1; returns null when ν ≤ p+1 (mean does not exist).
- Mode: mode[X] = Ψ / (ν + p + 1), defined for all ν > p.

### API shape

Following existing alea distribution patterns:
- `StaticWishart(T, dim)` / `StaticInverseWishart(T, dim)` structs with comptime-known dimension.
- Methods: `init` (validates parameters, errors on invalid), `new` (panics on invalid, debug asserts), `scaleValue`, `dfValue`, `dimensionValue`, `expectedValue`, `modeValue`, `sample`, `sampleFrom`.
- Samples are returned as stack-allocated `[dim][dim]T` row-major arrays.
- Error aliases: `WishartError = Error`, `InverseWishartError = Error`, where `Error` includes `InvalidParameter`/`InvalidCovariance` for non-PD scale or invalid df (consistent with existing multivariate normal error naming).

## Tests

7 new test cases validate:
1. Parameter validation: reject ν < dim, reject non-positive-definite scale matrix (diagonal zero entry).
2. Wishart 2D: samples are symmetric, positive-definite (Cholesky succeeds), all eigenvalues positive.
3. Wishart 3D: 5000-sample Monte Carlo mean matches νΨ within 0.3|expected| + 0.3 sampling tolerance (Wishart variance is large for finite samples).
4. Inverse-Wishart: samples are symmetric, positive-definite; product of Wishart and Inverse-Wishart samples is approximately the identity matrix (W W⁻¹ ≈ I, residual Frobenius norm < 0.1 for mean of 1000 products).
5. Cholesky inversion correctness: A A⁻¹ ≈ I for a known 3×3 PD matrix.
6. Free function and checked entry points work correctly.
7. f32 support: finiteness, symmetry, positive-definiteness.

Total test count: 748 passing (up from 741 before this milestone).

## Documentation

- `docs/api-reference.md` updated with all 21 new public symbols (error aliases + struct methods), verified by `zig build apicheck`.
- `compare/results/core-rand-coverage.md` updated with this S4-M1265 milestone entry.

## Coverage vs Rust rand

Rust `rand` 0.8 and `rand_distr` 0.4 provide **no Wishart or Inverse-Wishart distribution** in the core crate or standard `rand_distr` companion. Bayesian statistics users needing covariance priors must rely on external `nalgebra`/`statrs` crates or hand-roll Bartlett decomposition. This milestone adds both distributions as first-class citizens, further extending alea's feature breadth beyond the Rust baseline.

## Next steps

The next stricter product bar is open for:
- Bingham distribution (axial counterpart to Watson on Sⁿ⁻¹)
- Matrix von Mises-Fisher distribution (on Stiefel/manifold matrices)
- Kent distribution (Fisher-Bingham, 5-parameter spherical distribution)
- Dynamic-dimensional Wishart/Inverse-Wishart with allocator support for runtime dim
- Gaussian copula and other copula methods
- SIMD vectorization for multivariate/bulk sampling paths
- Longer multi-platform statistical validation runs
- Additional newly discovered core gaps against local Rust `rand`/`rand_distr` evidence
