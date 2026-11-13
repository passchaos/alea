# S4-M1296 — Allocator-backed multivariate skew-normal distribution

## Goal

Add the allocator-backed multivariate skew-normal distribution using the
Azzalini–Dalla Valle construction:

```
Y = δ|Z₀| + L·Z,   Z₀ ~ N(0,1),   Z ~ N(0, I),
X = ξ + Y,
```

where `δ = Ψα / √(1 + αᵀΨα)` and `L` is the Cholesky factor of `Ψ − δδᵀ`.
`α = 0` recovers `MultivariateNormal(ξ, Ψ)`. The distribution is absent from
local Rust `rand` / `rand_distr` core.

## Implementation

### Public API

`MultivariateSkewNormal(T)`:

- `init(allocator, location, scale, shape) !Self` / `new(...)`.
- `deinit`, `clone`.
- `dimensionValue`, `rankValue`, `isDegenerate`.
- `locationValues`, `locationAt`, `scaleAt`, `shapeValues`, `shapeAt`,
  `deltaValues`, `deltaAt`.
- `expectedValue(allocator) ![]T` / `expectedValueInto(out)` —
  `ξ + √(2/π)·δ`.
- `covarianceAt(row, col)`, `varianceAt(index)` — `Ψ − (2/π)·δδᵀ`.
- `sample` / `sampleFrom` (allocating), `sampleInto` / `sampleIntoFrom`
  (zero-alloc), checked variants, and `sampleManyInto` / `sampleManyIntoFrom`.

`multi.MultivariateSkewNormal(T)` re-exports the type.

### Sampling

Two inner `MultivariateNormal(T)` factors:

- the scale factor for `Ψ` (used by `scaleAt`/`covarianceAt` diagnostics),
- the residual factor for `Ψ − δδᵀ` (used for sampling).

Sampling draws the residual normal vector, draws `Z₀`, and applies
`ξ + δ|Z₀| + residual`. The stream order is residual normals then `Z₀`.

## Bug found during development

The first implementation used a scalar tail scale
`√(1 − δᵀδ)` instead of the residual Cholesky factor. That is only valid when
`Ψ − δδᵀ` is a multiple of the identity; for correlated `Ψ` it produced the
wrong covariance. The moment and manual-composition tests caught it; the
implementation now factors `Ψ − δδᵀ` and samples through that residual.

## Tests added (4 new, total 846)

1. `MultivariateSkewNormal alpha=0 reduces to multivariate normal` — zero
   delta, mean/covariance accessors, and 20,000-sample mean recovery.
2. `MultivariateSkewNormal sampling matches the Azzalini moments` — analytic
   `ξ + √(2/π)δ` mean and `Ψ − (2/π)δδᵀ` covariance vs 40,000 samples.
3. `MultivariateSkewNormal matches manual composition` — bit-for-bit parity
   against the explicit residual-Cholesky composition for the same stream.
4. `MultivariateSkewNormal clone, caller buffers, batches, and f32 work`.

## Validation

- `zig build test` passes: 846/846 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- Focused `zig test src/root.zig --test-filter "MultivariateSkewNormal"` passes
  4/4.
- `docs/api-reference.md` updated for all 28 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1296 row added.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
