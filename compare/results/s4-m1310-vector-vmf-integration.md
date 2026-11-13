# S4-M1310 — SIMD von Mises-Fisher integration: docs, distcheck, benchmark

## Goal

Integrate the S4-M1309 `VectorVonMisesFisher(T)` addition into the product
surface:

- README and core-guide discovery.
- `tools/distcheck.zig` statistical gate (also exercised on WASI).
- `bench/throughput.zig` throughput row.

## Changes

### Documentation

- README lists SIMD vector von Mises/von Mises-Fisher alongside the scalar
  directional families.
- `docs/core-guide.md` describes `VectorVonMises(T)` /
  `VectorVonMisesFisher(T)`: one independent sample per vector lane, lane
  retirement in the Best–Fisher/Wood rejection loops, and the `[3]VectorType`
  vMF output shape with shared mean/κ.

### Distcheck

`checkAdvancedMultivariate` gains an f64x4 `VectorVonMisesFisher` block with
`κ = 5` and mean `[0, 0, 1]`:

- 10,000 vector samples (40,000 lanes),
- every lane must be a unit vector within `1e-9`,
- the lane mean `z` component must match the scalar vMF mean resultant
  `coth(5) − 1/5` within `±0.03`,
- the block runs under `wasm32-wasi` through `zig build wasi-report`.

### Benchmark

`benchVectorVonMisesFisher` follows the existing 3-trial fixed-seed checksum
harness and is invoked from the `advanced multivariate throughput` section as
`alea vector von mises-fisher f64x4 3d`.

## Evidence

Command:
`zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216 "vector von mises-fisher"`

| Row | M samples/s | Lane-samples/s |
| --- | ---: | ---: |
| `alea von mises-fisher 3d` (scalar, S4-M1303) | 43.1 | 43.1 |
| `alea vector von mises-fisher f64x4 3d` | 9.9 | 39.6 |

The vector row is roughly at scalar parity per lane rather than faster: the
rejection loops, per-lane retirement, and `log`/`cos`/`acos` transcendentals
dominate, and the LLVM lowering may scalarize vector transcendentals on this
target. The API still provides one call per four independent samples and a
uniform `[3]VectorType` shape.

## Validation

- `zig build distcheck` passes with the new block.
- `zig build wasi-report` passes end-to-end and ends with `profilelongcheck ok`.
- `zig build test --summary all` passes 867/867 tests with all documentation
  gates.
- `compare/results/core-rand-coverage.md` S4-M1310 row added.

## Next bar

SIMD Kent/Watson/Bingham sampling, vector-directional table/squeeze
optimizations, further long-run goodness-of-fit checks, or newly discovered
core gaps.
