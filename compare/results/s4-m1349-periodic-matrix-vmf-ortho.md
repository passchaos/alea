# S4-M1349 — Periodic matrix vMF orthonormalization

## Goal

Remove the per-sweep Gram-Schmidt pass from the matrix vMF Gibbs sampler while
keeping the Stiefel columns orthonormal.

## Implementation

- The per-column conditional draws already produce a unit column orthogonal to
  the others up to floating-point rounding, so a full Gram-Schmidt pass after
  every sweep is unnecessary.
- `matrixVmfSweep` no longer orthonormalizes. `MatrixVonMisesFisher.advance`
  keeps an `ortho_countdown` field and runs `matrixVmfOrthonormalize` every 64
  sweeps, reinitializing only if the correction fails.
- `clone` copies the countdown, and the type documentation now states the
  64-sweep correction interval and the observed drift bound.

## Drift check

A 1,000,000-sample probe (10,000,000 sweeps) with `F = κ e₃e₁ᵀ`, κ = 5,
measured:

```
max_norm_err=6.710965116951684e-12 max_dot=5.977869654632487e-12
```

well below the `1e-10` orthonormalization tolerance and the tests' `1e-9`
bound.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 samples)

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea matrix von mises-fisher 3x2` | 0.5M samples/s | 0.6M samples/s | +20% |

The benchmark checksum changes to `18105066872339287869` and is stable across
five runs (the tiny inter-correction drift changes the conditional draws
slightly).

## Validation

- All 6 `MatrixVonMisesFisher` tests pass, including orthonormality, the
  zero-second-column vMF marginal, clone, and f32 paths.
- `zig build distcheck` passes; `zig build test` passes 897/897.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further Gibbs-sweep optimization, or newly discovered core gaps.
