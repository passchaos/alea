# S4-M1347 — Direct 2D vMF vector sampler

## Goal

Remove the angle-conversion round trip from the circular von Mises sampler used
by the matrix vMF Gibbs conditional, speeding up the slowest matrix sampler
without changing its distribution.

## Implementation

- New `vonMises2dPointFrom(source, T, mean_x, mean_y, kappa) [2]T` runs the
  Best–Fisher rejection algorithm with the stable `rho` formula and returns the
  unit vector directly:
  `x = f·mean + sign·√(1−f²)·perp`, where `f = cos δ` is the accepted
  Best–Fisher value and `perp = (−mean_y, mean_x)`.
- This avoids `atan2` (mean angle), `acos(f)` (delta), and the final
  `cos`/`sin` reconstruction.
- Used by:
  - `vonMisesFisherPointFrom` for `n = 2` (public 2D vMF),
  - `runtimeVonMisesFisherInto` for `dim = 2` (the matrix vMF Gibbs
    conditional that S4-M1332 routed away from the biased Wood S¹ path).

The rejection tests, squeeze, and Exp(1)-free slow test are unchanged, and the
RNG draw count/order is unchanged.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 samples)

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea matrix von mises-fisher 3x2` | 0.4M samples/s | 0.5M samples/s | +25% |

The benchmark checksum changes from `18105066877552417898` to
`18105066876596026287` because the vector is assembled from `f` instead of
`cos(acos(f))`; it is stable across five runs.

## Validation

- `zig test src/root.zig --test-filter "VonMisesFisher"` passes all 21 tests,
  including the 2D vMF and VectorKent β=0 parity.
- `zig test src/root.zig --test-filter "MatrixVonMisesFisher"` passes all 6
  tests, including the zero-second-column vMF marginal and orthonormality.
- `zig build distcheck` passes; `zig build test` passes 897/897.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further Gibbs-sweep optimization, or newly discovered core gaps.
