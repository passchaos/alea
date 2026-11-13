# S4-M1377 — Precomputed Wood constants for the exact single-column vMF

## Goal

Stop recomputing the Wood rejection constants on every exact single-column
matrix vMF draw; the mean norm is fixed for a given sampler.

## Implementation

- `MatrixVonMisesFisher.initWithOptions` computes
  `vmfWoodConstants(T, mean_norm, 3)` once for `cols == 1` and `rows == 3` and
  stores `b`, `x0`, `c` in the existing `h` buffer, which is unused on the
  exact single-column path. This keeps the struct size unchanged.
- `sampleExactK1From` for three rows handles `mean_norm == 0` (uniform
  sphere) and `mean_norm > 1e12` (point mass) explicitly, then draws
  `w` with `vmfSampleWWithConstantsFrom` and finishes with
  `vonMisesFisherFromW`, matching the previous `vonMisesFisherPointFrom`
  behavior.
- The sampled stream is unchanged; only the per-draw constant computation is
  removed.

## Layout note

Storing the constants in three new struct fields achieved the same gain but
shifted the hot skew-normal loop layout and dipped `alea skew-normal` by
about 2.3% (583M → 569M). Reusing the `h` buffer avoids the struct-size
change: `skew-normal` is back at 574-582M while the 3×1 row keeps its gain.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea matrix von mises-fisher 3x1` | 33.6M samples/s | 44.8M samples/s | +33% |
| `alea matrix von mises-fisher 3x2` | 36.8M samples/s | 36.8M samples/s | unchanged |
| `alea skew-normal` | 583M samples/s | 578M samples/s | within noise |

The 3×1 checksum remains `13936223317007019539` and the 3×2 checksum
`5952472309509111602`.

## Validation

- All 7 matrix vMF tests pass.
- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
precomputed constants for the runtime-dimension single-column path, or newly
discovered core gaps.
