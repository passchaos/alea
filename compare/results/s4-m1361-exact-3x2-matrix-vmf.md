# S4-M1361 — Exact 3×2 matrix vMF sampling through SO(3)

## Goal

Replace the approximate 10-sweep Gibbs chain for the 3×2 matrix Langevin
distribution with exact, independent sampling by reusing the existing SO(3)
matrix Fisher sampler.

## Mathematical reduction

The Stiefel manifold V_{3,2} (3×2 matrices with orthonormal columns) is
diffeomorphic to SO(3): complete each frame with the cross product of its two
columns. For `X = [x₀ x₁]` and `R = [x₀ x₁ x₀×x₁]`,

```
tr(FᵀX) = f₀·x₀ + f₁·x₁ = tr(KᵀR),   K = [f₀ f₁ 0].
```

Haar measure on SO(3) pushes forward to the uniform measure on V_{3,2}, so the
first two columns of `R ~ MatrixFisher(K)` have exactly the matrix Langevin
density `exp(tr(FᵀX))`. The existing `MatrixFisher` sampler is exact: it
reduces the density to a Bingham distribution on S³ and rejection-samples it.

## Implementation

- `MatrixVonMisesFisher(T)` stores an optional `exact_3x2: MatrixFisher(T)`
  built in `initWithOptions` when `rows == 3 and cols == 2`, with the third
  parameter column set to zero.
- `sampleIntoFrom` and `sampleManyIntoFrom` dispatch to the exact sampler and
  copy the first two columns of the rotation; other shapes keep the Gibbs
  path unchanged.
- `burnin` and `thin` are ignored for 3×2 (draws are independent); the 3×2
  Gibbs kernel remains as a fallback when the matrix Fisher construction is
  rejected (for example for extreme parameter scales).
- The type documentation now states the exact 3×2 contract.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea matrix von mises-fisher 3x2` | 1.0M samples/s | 33.6M samples/s | ~33× |

The checksum changes to `5952472309509111602` and is stable across runs. The
new draws are independent exact samples rather than correlated Gibbs draws.

## Statistical checks

- The zero-second-column test now draws 100,000 samples: the first column
  mean is `(0.000, 0.002, 0.799)` against the exact vMF mean resultant
  `0.800`, and all second-column means stay inside the `0.01` gate.
- Orthonormality, clone, f32, and the generic 4×2/4×3 Gibbs-shape tests pass.
- The `distcheck` advanced-multivariate matrix vMF gates pass on native and
  WASI.

## Validation

- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
exact reductions for other Stiefel shapes, or newly discovered core gaps.
