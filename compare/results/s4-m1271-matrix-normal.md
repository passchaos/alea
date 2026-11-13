# S4-M1271 — Matrix normal distribution

## Goal

Add the matrix normal distribution `MN(M, U, V)` over rows×cols matrices:

```
f(X) ∝ exp(-½·tr(V⁻¹ (X−M)ᵀ U⁻¹ (X−M))),
```

where `M` is the rows×cols mean, `U` is the rows×rows row covariance, and `V`
is the cols×cols column covariance. The matrix normal is the natural
matrix-variate companion to `MultivariateNormal`, `Wishart`, and
`InverseWishart`, used for matrix-variate regression, spatio-temporal models,
and Bayesian matrix priors. It is absent from local Rust `rand` / `rand_distr`
core.

## Implementation

### Public API

`MatrixNormal(T)`:

- `init(allocator, mean: []const T, row_covariance: []const T, col_covariance: []const T) !Self`
  / `new(...) !Self`
- `deinit(*Self)`, `clone(self, allocator) !Self`
- `rowsValue`, `colsValue`
- `meanValues`, `meanAt(row, col)`
- `expectedValue(allocator) ![]T`, `expectedValueInto(out) Error!void`
- `modeValue(allocator) ![]T`, `modeInto(out) Error!void`
- `rowCovarianceAt(row, col)`, `colCovarianceAt(row, col)`, `varianceAt(row, col)`
- `sample(allocator, rng) ![]T`, `sampleFrom(allocator, source) ![]T`
- `sampleInto(rng, out)`, `sampleIntoFrom(source, out)` (zero-alloc)
- `sampleIntoChecked` / `sampleIntoCheckedFrom`
- `sampleManyInto` / `sampleManyIntoFrom` (zero-alloc batch)

`multi.MatrixNormal(T)` re-exports the type, and `MatrixNormalError` aliases
the distribution `Error` set.

### Dimensions and validation

- `row_covariance.len` and `col_covariance.len` must be perfect squares; the
  square roots define `rows` and `cols`.
- `mean.len` must equal `rows * cols` exactly.
- Mean entries must be finite; covariance entries must be finite and each
  covariance must factor as a finite symmetric positive-semidefinite matrix
  through the existing `factorMultivariateCovariance` helper.
- Rank-deficient row/column covariances are supported by the existing factor
  path.

### Sampling

```
X = M + L_U Z L_Vᵀ,   U = L_U L_Uᵀ,   V = L_V L_Vᵀ,   Z_ij ~ N(0,1).
```

The transform is performed in place on the output buffer:

1. Fill the output with iid standard normals.
2. Left-multiply by the lower-triangular `L_U` column by column, processing
   rows bottom-up so unmodified `Z` rows remain available.
3. Right-multiply by `L_Vᵀ` row by row, processing columns right-to-left so
   unmodified `Y = L_U Z` columns remain available.
4. Add the mean.

No scratch allocation is required on the hot path; only `init` and `clone`
allocate.

## Tests added (6 new, total 801)

1. `MatrixNormal constructor validates parameters` — empty mean, non-square
   covariance lengths, mismatched mean length, non-finite mean/covariance, and
   non-PSD row covariance.
2. `MatrixNormal identity covariances produce iid standard normals` — 10,000
   samples; each entry has mean ≈ 0, variance ≈ 1, and cross-covariance ≈ 0.
3. `MatrixNormal recovers row and column covariance` — 20,000 samples with
   `U = [[1,0.6],[0.6,1]]` and `V = [[1,0.4],[0.4,1]]`; empirical cross
   moments match, and the covariance accessors reproduce the inputs.
4. `MatrixNormal recovers a non-zero mean` — 2×3 mean recovered within 0.04,
   plus `meanAt` bounds checking.
5. `MatrixNormal clone, caller buffers, and batches work` — clone, checked
   output lengths, batch fills, allocating samples, and mean/mode exports.
6. `MatrixNormal f32 and direct-source parity` — bit-for-bit facade/direct
   streams for f32.

## Validation

- `zig build test` passes: 801/801 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- Focused `zig test src/root.zig --test-filter "MatrixNormal"` passes 6/6.
- `docs/api-reference.md` updated for all 26 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1271 row added.

## Deviations and notes

- Only the allocator-backed runtime-dimension variant is provided; a
  comptime-dimension `StaticMatrixNormal(T, rows, cols)` can follow the
  `StaticMultivariateNormal` pattern if allocation-free fixed-size workflows
  are needed.
- The row and column covariances use the same positive-semidefinite factoring
  path as `MultivariateNormal`, so singular covariances are accepted and
  produce deterministic/rank-deficient draws rather than errors.
- The in-place transform avoids per-sample scratch but intentionally processes
  rows/columns in the reverse order documented above; the tests recover both
  covariance factors, which would fail if either direction were wrong.

## Next bar

Static matrix normal, Matrix von Mises-Fisher, Kent distribution, vector/SIMD
copula/Bingham sampling, longer statistical validation runs, or newly
discovered core gaps against local Rust `rand` / `rand_distr` evidence.
