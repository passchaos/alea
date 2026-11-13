# S4-M1305 — Matrix von Mises-Fisher (matrix Langevin) distribution

## Goal

Add the matrix Langevin distribution L(F) on the Stiefel manifold V_{k,p}:
p×k matrices `X` with `XᵀX = I_k` and density

```
f(X) ∝ etr(FᵀX) = exp(tr(FᵀX)).
```

This is the matrix-variate companion to `VonMisesFisher`, and is absent from
local Rust `rand` / `rand_distr` core.

## Implementation

### Public API

`MatrixVonMisesFisher(T)`:

- `init(allocator, parameter, rows, cols)` with default burn-in 100 and
  thinning 10; `initWithOptions(..., burnin, thin)` for explicit chain
  settings; `new` is the debug-only panicking constructor.
- `deinit`, `clone`.
- `rowsValue`, `colsValue`, `burninValue`, `thinValue`, `parameterAt`.
- `sample` / `sampleFrom` (allocating), `sampleInto` / `sampleIntoFrom`
  (caller-owned), and `sampleManyInto` / `sampleManyIntoFrom`.

`multi.MatrixVonMisesFisher(T)` re-exports the type, and
`MatrixVonMisesFisherError` aliases the shared distribution error set.

### Sampling

The sampler uses the standard Gibbs sampler for the matrix Langevin:

- The chain state `X` is initialized uniformly on V_{k,p} via a Gaussian
  matrix followed by modified Gram-Schmidt.
- Each sweep updates every column `x_j`. Given the other columns, the exact
  conditional density of `x_j` is von Mises-Fisher on the orthogonal
  complement of the other columns, with mean direction equal to the
  projection of `F_j` and concentration equal to its norm.
- A runtime-dimension vMF helper (`vmfSampleWFrom` + a runtime Householder
  reflection) samples the conditional; a runtime unit-sphere helper supplies
  the uniform tangent direction.
- `sampleInto` runs burn-in once, then `thin` sweeps per output;
  `sampleManyInto` runs burn-in once and thins between outputs, keeping the
  chain state across calls.

The implementation requires `p > k`. For square orthogonal matrices (`p = k`)
the conditional complement is one-dimensional and the fixed-sweep chain is
periodic, so the constructor rejects that case instead of returning biased
samples. This is documented in the type.

### Initialization and stability

- `matrixVmfComplement` builds the complement basis by modified Gram-Schmidt
  over the standard basis, skipping columns already in the span.
- After every sweep the state is re-orthonormalized to control floating-point
  drift; if orthonormalization fails the chain is reinitialized uniformly.

## Tests added (5 new, total 858)

1. Constructor validation: `cols ≥ rows`, zero dimensions, wrong parameter
   length, `thin = 0`, and non-finite entries.
2. `k = 1` reduction: with a 3×1 parameter the chain is exactly
   `VonMisesFisher(T, 3)`; the 20,000-sample mean matches
   `ρ·μ` with `ρ = coth(κ) − 1/κ`.
3. Zero second column: with `F = [F₁ 0]` the first column is vMF and the
   second is uniform on its complement; both sample means match the exact
   expectations over 20,000 draws.
4. Orthonormality and batch sampling for a 3×2 parameter, including
   `sampleManyInto`.
5. Clone parity (bit-for-bit chain continuation) and f32 support.

## Validation

- `zig test src/root.zig --test-filter "MatrixVonMisesFisher"` passes 5/5.
- `zig build test --summary all` passes 858/858 tests; `apicheck` and all
  documentation gates are green.
- `docs/api-reference.md` updated for all 18 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1305 row added.

## Notes and next bar

The Gibbs sampler is an approximate (correlated) sampler, not an exact
independent sampler; this is documented on the type and controlled by
burn-in/thinning. Exact sampling for square `p = k` matrices (matrix Fisher
on SO(3)) remains a future enhancement.

Next bar: Matrix vMF docs/distcheck/benchmark integration, SO(3) matrix
Fisher sampling, vector/SIMD directional sampling, or newly discovered core
gaps.
