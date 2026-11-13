# S4-M1294 — Allocator-backed multivariate Laplace distribution

## Goal

Add the allocator-backed multivariate Laplace distribution:

```
f(x) ∝ exp(-√(2·(x−μ)ᵀΣ⁻¹(x−μ))),   E[x] = μ,   Cov[x] = Σ.
```

It is the heavy-tailed elliptical companion to `MultivariateNormal(T)` and
`MultivariateT(T)`, and is absent from local Rust `rand` / `rand_distr` core.

## Implementation

### Public API

`MultivariateLaplace(T)`:

- `init(allocator, mean, covariance) !Self` / `new(...)`.
- `deinit`, `clone`.
- `dimensionValue`, `rankValue`, `isDegenerate`.
- `meanValues`, `meanAt`.
- `scaleAt(row, col)`, `varianceAt(index)`, `covarianceAt(row, col)`.
- `sample` / `sampleFrom` (allocating), `sampleInto` / `sampleIntoFrom`
  (zero-alloc), checked variants, and `sampleManyInto` / `sampleManyIntoFrom`.

`multi.MultivariateLaplace(T)` re-exports the type.

### Sampling

Scale-mixture representation:

```
z ~ N(0, Σ),   s ~ Exp(1),   x = μ + √s·z.
```

The inner `MultivariateNormal(T)` owns the mean and Cholesky factor; sampling
draws `μ + z`, subtracts the mean, multiplies by `√s`, and adds the mean back.
This is exact and rejection-free.

## Tests added (3 new, total 842)

1. `MultivariateLaplace constructor and sampling moments work` — empty-mean
   rejection, accessors, and 40,000-sample mean/variance/covariance recovery
   for a correlated 2D scale matrix with a non-zero mean.
2. `MultivariateLaplace matches manual normal plus exponential composition` —
   bit-for-bit parity against the explicit
   `mean + (mvn − mean)·√Exp(1)` composition for the same stream.
3. `MultivariateLaplace clone, caller buffers, batches, and f32 work` — clone,
   checked output lengths, batch fills, allocating samples, and f32 support.

## Validation

- `zig build test` passes: 842/842 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- Focused `zig test src/root.zig --test-filter "MultivariateLaplace"` passes
  3/3.
- `docs/api-reference.md` updated for all 22 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1294 row added.

## Notes

- The parameterization uses the standard scale-mixture form whose covariance is
  exactly Σ; the density carries the `√2` factor implied by `s ~ Exp(1)`.
- The sampler is allocation-free after construction; only `init`/`clone` and
  allocation-returning sample helpers allocate.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
