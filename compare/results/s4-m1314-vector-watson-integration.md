# S4-M1314 — SIMD Watson integration: docs, distcheck, benchmark

## Goal

Integrate the S4-M1313 `VectorWatson(T)` addition into the product surface:

- README and core-guide discovery.
- `tools/distcheck.zig` statistical gate (also exercised on WASI).
- `bench/throughput.zig` throughput row.

## Changes

### Documentation

- README lists SIMD vector Watson alongside the vector von Mises/vMF samplers.
- `docs/core-guide.md` describes `VectorWatson(T)`: per-lane S² axial
  sampling, lane retirement, the `[3]VectorType` output shape, and shared
  axis/concentration.

### Distcheck

`checkAdvancedMultivariate` gains an f64x4 `VectorWatson` block with
`κ = 5` and axis `[0, 0, 1]`:

- 10,000 vector samples (40,000 lanes),
- every lane must be a unit vector within `1e-9`,
- the lane `E[z²]` must match the corrected scalar
  `Watson.meanCosineSquared()` (`0.764266…`) within `±0.03`,
- the block runs under `wasm32-wasi` through `zig build wasi-report`.

### Benchmark

`benchVectorWatson` follows the existing 3-trial fixed-seed checksum harness
and is invoked from the `advanced multivariate throughput` section as
`alea vector watson f64x4 3d`.

## Evidence

Command:
`zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216 "vector watson"`

| Row | M samples/s | Lane-samples/s |
| --- | ---: | ---: |
| `alea watson 3d` (scalar, S4-M1301) | 15.7 | 15.7 |
| `alea vector watson f64x4 3d` | 2.8 | 11.2 |

The vector row is slower per lane than the scalar sampler: the Watson
acceptance rate at `κ = 5` is about 20%, each round draws full vectors even
for retired lanes, and vector `log` lowering may scalarize on this target.
The API still provides one call per four independent samples.

## Validation

- `zig build distcheck` passes with the new block.
- `zig build wasi-report` passes end-to-end and ends with `profilelongcheck ok`.
- `zig build test --summary all` passes 871/871 tests with all documentation
  gates.
- `compare/results/core-rand-coverage.md` S4-M1314 row added.

## Next bar

SIMD Kent/Bingham sampling, vector-directional squeeze optimizations, further
long-run goodness-of-fit checks, or newly discovered core gaps.
