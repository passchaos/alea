# S4-M1318 — SIMD Kent integration: docs, distcheck, benchmark

## Goal

Integrate the S4-M1317 `VectorKent(T)` addition into the product surface:

- README and core-guide discovery.
- `tools/distcheck.zig` statistical gate (also exercised on WASI).
- `bench/throughput.zig` throughput row.

## Changes

### Documentation

- README lists SIMD vector Kent alongside the vector von Mises/vMF/Watson/
  Bingham samplers.
- `docs/core-guide.md` describes `VectorKent(T)`: per-lane S² Kent sampling,
  the shared frame/κ/β, the `[3]VectorType` output shape, and lane retirement
  in the Wood/I₀ acceptance loop.

### Distcheck

`checkAdvancedMultivariate` gains an f64x4 `VectorKent` block with
`κ = 5`, `β = 1.5`, mean `[0, 0, 1]`, and major axis `[1, 0, 0]`:

- 10,000 vector samples (40,000 lanes),
- every lane must be a unit vector within `1e-9`,
- the lane mean `z` must match the scalar Kent mean resultant within `±0.03`,
- the block runs under `wasm32-wasi` through `zig build wasi-report`.

### Benchmark

`benchVectorKent` follows the existing 3-trial fixed-seed checksum harness
and is invoked from the `advanced multivariate throughput` section as
`alea vector kent f64x4 3d`.

## Evidence

Command:
`zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216 "vector kent"`

| Row | M samples/s | Lane-samples/s |
| --- | ---: | ---: |
| `alea kent 3d` (scalar, S4-M1300) | 14.4 | 14.4 |
| `alea vector kent f64x4 3d` | 3.8 | 15.2 |

The vector row is roughly at scalar parity per lane (slightly faster), unlike
the Watson/Bingham vector paths, because the Kent marginal acceptance is high
(~94%) and the conditional von Mises work is amortized across four lanes.

## Validation

- `zig build distcheck` passes with the new block.
- `zig build wasi-report` passes end-to-end and ends with `profilelongcheck ok`.
- `zig build test --summary all` passes 876/876 tests with all documentation
  gates.
- `compare/results/core-rand-coverage.md` S4-M1318 row added.

## Next bar

Vector-directional squeeze optimizations, further long-run goodness-of-fit
checks, broader platform evidence, or newly discovered core gaps.
