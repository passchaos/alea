# S4-M1316 — SIMD Bingham integration: docs, distcheck, benchmark

## Goal

Integrate the S4-M1315 `VectorBingham(T)` addition into the product surface:

- README and core-guide discovery.
- `tools/distcheck.zig` statistical gate (also exercised on WASI).
- `bench/throughput.zig` throughput row.

## Changes

### Documentation

- README lists SIMD vector Bingham alongside the vector von Mises/vMF/Watson
  samplers.
- `docs/core-guide.md` describes `VectorBingham(T)`: per-lane S² Bingham
  sampling, ACG lane retirement, the `[3]VectorType` output shape, and the
  shared quadratic-form matrix.

### Distcheck

`checkAdvancedMultivariate` gains an f64x4 `VectorBingham` block with
`diag(0, −3, −3)`:

- 10,000 vector samples (40,000 lanes),
- every lane must be a unit vector within `1e-9`,
- the lane `E[x0²]` must match the direct numerical integral
  `∫ w² exp(3w²) dw / ∫ exp(3w²) dw` within `±0.03`,
- the block runs under `wasm32-wasi` through `zig build wasi-report`.

### Benchmark

`benchVectorBingham` follows the existing 3-trial fixed-seed checksum harness
and is invoked from the `advanced multivariate throughput` section as
`alea vector bingham f64x4 3d`.

## Evidence

Command:
`zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216 "bingham"`

| Row | M samples/s | Lane-samples/s |
| --- | ---: | ---: |
| `alea bingham 3d` (scalar) | 26.0 | 26.0 |
| `alea vector bingham f64x4 3d` | 4.8 | 19.2 |

The vector row is slower per lane than the scalar sampler: each round draws
full vectors even for retired lanes, and the acceptance ratio uses vector
`log`/`log1p`-style math that may scalarize on this target. The API still
provides one call per four independent samples.

## Validation

- `zig build distcheck` passes with the new block.
- `zig build wasi-report` passes end-to-end and ends with `profilelongcheck ok`.
- `zig build test --summary all` passes 873/873 tests with all documentation
  gates.
- `compare/results/core-rand-coverage.md` S4-M1316 row added.

## Next bar

SIMD Kent sampling, vector-directional squeeze optimizations, further long-run
goodness-of-fit checks, or newly discovered core gaps.
