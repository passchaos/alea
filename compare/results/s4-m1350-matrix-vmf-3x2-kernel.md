# S4-M1350 — Comptime-specialized 3×2 matrix vMF Gibbs kernel

## Goal

Cut the remaining per-sweep overhead from the matrix von Mises-Fisher Gibbs
sampler for the benchmarked 3×2 Stiefel shape without changing the generic
runtime-dimension path.

## Implementation

- `matrixVmfSweep` dispatches `rows == 3 and cols == 2` to a fully unrolled
  `matrixVmfSweep3x2` kernel; every other shape keeps the generic
  Gram-Schmidt path unchanged.
- For a 3×2 Stiefel matrix the orthogonal complement of either column is
  spanned by the other column and their normalized cross product, so the
  generic candidate-scanning Gram-Schmidt complement construction collapses
  to one cross product per sweep.
- The second complement basis follows algebraically from the first circle
  draw: for an orthonormal basis `c0' × c1 = z0[0] * n - z0[1] * c0`, so no
  second cross product or normalization is needed.
- The per-column conditional still draws from the exact 2D von Mises-Fisher
  law (`vonMises2dPointFrom`) or the uniform circle fallback, and the periodic
  64-sweep Gram-Schmidt correction is unchanged.
- `vonMises2dPointFrom` cancels the `disc + 1` factor against the leading
  `tau` in the Best–Fisher `rho` expression, saving one multiply and one
  division per conditional draw.
- A new unit test covers the generic 4×2 and 4×3 shapes so both sweep paths
  stay exercised.

## Drift check

A 1,000,000-sample probe (10,000,000 sweeps) with `F = κ e₃e₁ᵀ`, κ = 5,
measured:

```
max_norm_err=2.220446049250313e-15 max_dot=9.43689570931383e-16
```

well below the 64-sweep correction tolerance.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 samples)

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea matrix von mises-fisher 3x2` | 0.6M samples/s | 1.0M samples/s | +67% |

A 5,000,000-sample probe measured 0.5997M samples/s before and 1.0041M after
(+67.4%). The benchmark checksum changes from `18105066872339287869` to
`2714558339856361647` because the specialized kernel uses a different
(equally valid) complement basis, and is stable across three runs.

## Validation

- All 7 `MatrixVonMisesFisher` tests pass, including the new generic 4×2/4×3
  orthonormality test.
- `zig build distcheck` passes; `zig build test` passes 898/898.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further Gibbs-sweep or 2D vMF kernel optimization, or newly discovered core
gaps.
