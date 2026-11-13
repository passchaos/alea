# S4-M1308 — Matrix Fisher integration: docs, distcheck, benchmark

## Goal

Integrate the S4-M1307 `MatrixFisher(T)` addition into the surrounding product
surface:

- README and core-guide discovery.
- `tools/distcheck.zig` statistical gate (also exercised on WASI).
- `bench/throughput.zig` throughput row.

## Changes

### Documentation

- README lists matrix Fisher on SO(3) and `multi.MatrixFisher`.
- `docs/core-guide.md` describes the density `exp(tr(FᵀR))`, the quaternion
  reduction `tr(F) + qᵀAq`, the exact Bingham-on-S³ sampling path, and the
  absence of burn-in/thinning.

### Distcheck

`checkAdvancedMultivariate` gains an isotropic `F = 2I` Matrix Fisher block:

- the exact `E[tr(R)]` is computed from the S³ Bingham marginal
  `p(w) ∝ exp(4d·w²)√(1−w²)` by deterministic numerical integration,
- 20,000 samples must match that expectation within `±0.03`,
- the block needs no allocator and runs under `wasm32-wasi` through
  `zig build wasi-report`.

### Benchmark

`benchMatrixFisher` follows the existing 3-trial fixed-seed checksum harness
and is invoked from the `advanced multivariate throughput` section as
`alea matrix fisher so3`, using
`F = [[0.8, −0.2, 0.3], [0.4, 0.6, −0.1], [−0.5, 0.2, 0.9]]`.

## Evidence

Command:
`zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216 "matrix fisher"`

| Row | M samples/s |
| --- | ---: |
| `alea matrix fisher so3` | 18.9 |

The exact Bingham reduction avoids burn-in/thinning, so throughput is close
to the spherical Bingham sampler plus the quaternion-to-matrix conversion.

## Validation

- `zig build distcheck` passes with the new block.
- `zig build wasi-report` passes end-to-end and ends with `profilelongcheck ok`.
- `zig build test --summary all` passes 862/862 tests with all documentation
  gates.
- `compare/results/core-rand-coverage.md` S4-M1308 row added.

## Next bar

Vector/SIMD directional sampling, further long-run goodness-of-fit checks, or
newly discovered core gaps against local Rust `rand` / `rand_distr` evidence.
