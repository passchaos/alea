# S4-M1292 — Allocator-backed multivariate Student-t distribution

## Goal

Add the allocator-backed multivariate Student-t distribution:

```
x = μ + z / √(s/ν),   z ~ N(0, Σ),   s ~ χ²(ν),
```

the heavy-tailed multivariate companion to `MultivariateNormal(T)` and the
vector form of the matrix-t family. It is absent from local Rust
`rand` / `rand_distr` core.

## Implementation

### Public API

`MultivariateT(T)`:

- `init(allocator, mean, covariance, degrees_of_freedom) !Self` / `new(...)`.
- `deinit`, `clone`.
- `dimensionValue`, `rankValue`, `isDegenerate`, `degreesOfFreedomValue`, `dfValue`.
- `meanValues`, `meanAt`.
- `scaleAt(row, col)` — input scale matrix Σ.
- `varianceAt(index) Error!?T` — `Σ_ii·ν/(ν−2)` for `ν > 2`, null otherwise.
- `covarianceAt(row, col) Error!?T` — `Σ_ij·ν/(ν−2)` for `ν > 2`, null otherwise.
- `sample` / `sampleFrom` (allocating), `sampleInto` / `sampleIntoFrom`
  (zero-alloc), checked variants, and `sampleManyInto` / `sampleManyIntoFrom`.

`multi.MultivariateT(T)` re-exports the type.

### Sampling

The inner `MultivariateNormal(T)` owns the mean and Cholesky factor. Sampling
draws `μ + z` from the MVN, draws one shared `χ²(ν)` scale, and computes:

```zig
value = mean + (value - mean) / scale
```

so only the centered component is scaled. The location mean is never divided by
the chi-squared scale.

## Bug found during development

The first implementation divided the entire MVN draw by the scale, which also
scaled the location mean. Diagnostics showed a 15–30% variance inflation and a
mean shifted away from zero. The corrected `mean + (value − mean)/scale` form
restores the standard multivariate-t construction; the 20,000-sample moment
test now matches `Σ·ν/(ν−2)`.

## Tests added (3 new, total 839)

1. `MultivariateT constructor, moments, and sampling work` — invalid df,
   dimension/df/scale accessors, `ν=5` variance `5/3`, 20,000-sample mean and
   variance recovery for a correlated 3D covariance, and null variance at ν=2.
2. `MultivariateT matches manual multivariate-normal plus chi-squared
   composition` — bit-for-bit parity against the explicit
   `mean + (mvn − mean)/scale` composition for the same stream.
3. `MultivariateT clone, caller buffers, batches, and f32 work` — clone,
   checked output lengths, batch fills, allocating samples, and f32 support.

## Validation

- `zig build test` passes: 839/839 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- Focused `zig test src/root.zig --test-filter "MultivariateT"` passes 3/3.
- `docs/api-reference.md` updated for all 24 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1292 row added.

## Notes

- `scaleAt` returns the input covariance Σ; `varianceAt`/`covarianceAt` return
  the actual t moments and null when they are infinite.
- The sampler is allocation-free after construction; only `init`/`clone` and
  the allocation-returning sample helpers allocate.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
