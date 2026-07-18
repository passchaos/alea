# S4-M1264: Vector/SIMD sampling for S4-M1253–M1263 distributions

**Date:** 2026-07-19
**Milestone:** S4-M1264
**Gate:** `zig build validate` passes; 752/752 tests pass; all 11 distributions have full vector API families matching existing core distribution pattern; api-reference is complete.

## Summary

Added vectorized SIMD sampling support for the 11 distributions added in milestones S4-M1253 through S4-M1263, closing the vectorization gap between recently-added scalar distributions and the core distribution set:
- Rice (S4-M1253)
- Nakagami-m (S4-M1254)
- InverseGamma (S4-M1255)
- ExGaussian (S4-M1256)
- GeneralizedPareto (GPD, S4-M1257)
- ScaledInverseChiSquared (S4-M1258)
- Hoyt (Nakagami-q, S4-M1259)
- NoncentralChiSquared (S4-M1260)
- NoncentralT (S4-M1261)
- NoncentralF (S4-M1262)
- NoncentralChi (S4-M1263)

Each distribution now follows the established alea vector API pattern, providing:
1. 8 vector free functions: `vectorXxx`, `vectorXxxFrom`, `vectorXxxChecked`, `vectorXxxCheckedFrom`, `fillVectorXxx`, `fillVectorXxxFrom`, `fillVectorXxxChecked`, `fillVectorXxxCheckedFrom`
2. A generic `VectorXxx(VectorType)` reusable sampler struct with the same accessor/method API as the scalar `Xxx(T)` struct
3. Internal vector composition helpers for distributions expressible as pointwise SIMD transforms of primitive vector draws

## Design Decisions

### True SIMD vs per-lane fallback

Following existing convention from `VectorGamma` and core distributions:
- **True SIMD (pointwise vector transforms):** Used for distributions expressible as algebraic combinations of primitive SIMD primitives (`vectorStandardNormal`, `vectorStandardExponential`, `vectorOpen` uniform):
  - Rice: `σ * @sqrt((ν + z1)^2 + z2^2)` from two standard normals (true SIMD)
  - Hoyt: `σ * @sqrt(z1^2 + (q*z2)^2)` from two standard normals (true SIMD)
  - ExGaussian: `μ + σ*z + τ*e` from normal + exponential (true SIMD)
  - GeneralizedPareto: inverse-CDF on uniform `vectorOpen` (true SIMD for both ξ=0 exponential limit and general ξ)
  - NoncentralT: `(z + μ) * @sqrt(ν / v)` from normal + VectorChiSquared (true SIMD, ν=∞ maps to vectorStandardNormal shifted by μ)
  - InverseGamma: `1 / gamma` from VectorGamma (true SIMD reciprocation; shape=1 uses SIMD exponential fast path)
  - ScaledInverseChiSquared: delegates to VectorInverseGamma via the ScaledInvChiSq = InverseGamma(ν/2, ντ²/2) identity (true SIMD)
  - NoncentralChi: `@sqrt(nc2)` from VectorNoncentralChiSquared (true SIMD sqrt pointwise)
  - **λ=0 fast path for all noncentral distributions:** Delegates to the corresponding central VectorChiSquared/VectorFisherF/VectorChi for full SIMD throughput
- **Per-lane scalar fallback (inline for over lanes):** Used for distributions requiring per-lane conditioning due to discrete Poisson-mixture sampling or shape-dependent rejection constants:
  - NoncentralChiSquared with λ>0: Poisson mixture of central chi-squareds (each lane needs an independent Poisson draw conditioning the DoF, which is not efficiently vectorizable without complex lane masking)
  - NoncentralF with λ>0: Depends on λ>0 NCχ², inherits per-lane fallback
  - NoncentralChi with λ>0: sqrt of λ>0 NCχ², inherits per-lane fallback
  - Nakagami general m: Wraps Gamma(m, Ω/m); general-shape Gamma uses per-lane fallback consistent with VectorGamma policy (shape=1 exponential is SIMD)

### Degenerate cases

All zero/degenerate cases return splatted zero (or appropriate constant) vectors without consuming randomness, consistent with existing vector distribution behavior.

### Accessor parity

All `VectorXxx(VectorType)` structs delegate accessor methods to the underlying scalar sampler, providing identical API surface to scalar samplers for mean/variance/parameter access while operating on vector types for sampling.

## Tests

11 new test cases (one per distribution) validate:
- Constructor parameter validation (invalid parameters return errors and do not consume randomness)
- Accessor method parity with scalar samplers
- Degenerate zero behavior (all-zero splats without stream consumption)
- λ=0 central-distribution fast path delegation for noncentral distributions
- Support properties (non-negativity, finiteness, domain correctness)
- Fill API correctness across multiple vectors
- Free function and checked/non-checked entry points
- q=1 Rayleigh equivalence for Hoyt
- ξ=0 exponential equivalence for GPD
- ScaledInverseChiSquared init parameterization (takes τ², scaleValue returns τ)

Total test count: 752 passing (up from 741 before this change).

## Documentation

- `docs/api-reference.md` updated with all 264 new public symbols (24 per distribution: 8 free functions, 1 VectorXxx struct, 1 init, 1 new, and 13 accessor/method entries per distribution), verified by `zig build apicheck`.
- `compare/results/core-rand-coverage.md` updated with this S4-M1264 milestone entry.

## Next steps

The next stricter product bar is open for:
- Truncated Normal distribution (missing from Rust `rand_distr` core set; common in Bayesian statistics and constrained sampling)
- Bingham distribution (directional statistics on the sphere)
- Matrix von Mises-Fisher distribution
- Kent distribution
- Copula methods
- Longer statistical validation runs
- Newly discovered core gaps against local Rust `rand`/`rand_distr` evidence
- Performance benchmarking of the new vector paths
