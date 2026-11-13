# S4-M1306 — Matrix von Mises-Fisher integration: docs, distcheck, benchmark

## Goal

Integrate the S4-M1305 `MatrixVonMisesFisher(T)` addition into the surrounding
product surface:

- README and core-guide discovery.
- `tools/distcheck.zig` statistical gate (also exercised on WASI).
- `bench/throughput.zig` throughput row.

## Changes

### Documentation

- README lists matrix von Mises-Fisher (matrix Langevin) and
  `multi.MatrixVonMisesFisher`.
- `docs/core-guide.md` describes the Stiefel-manifold density
  `exp(tr(FᵀX))`, the Gibbs conditional updates, the `p > k` requirement, and
  the periodic square-matrix limitation.

### Distcheck

`checkAdvancedMultivariate` gains a 3×2 `MatrixVonMisesFisher` block with
`F = [[0, 0], [0, 0], [5, 0]]` and burn-in 100 / thinning 10:

- the first column must have mean `z ≈ ρ = coth(5) − 1/5` within `±0.03`,
- the second column must have zero mean on all three coordinates within
  `±0.03` (it is uniform on the complement when its parameter column is zero),
- the allocator is target-conditional (`wasm_allocator` on WASI,
  `smp_allocator` natively), so the Gibbs sampler is exercised under
  `wasm32-wasi` through `zig build wasi-report`.

### Benchmark

`benchMatrixVonMisesFisher` follows the existing 3-trial fixed-seed checksum
harness and is invoked from the `advanced multivariate throughput` section as
`alea matrix von mises-fisher 3x2`, using `F = [[0.8, 0.2], [-0.1, 0.6], [0.3, -0.4]]`
and the default burn-in/thinning.

## Evidence

Command:
`zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216 "matrix von mises-fisher"`

| Row | M samples/s |
| --- | ---: |
| `alea matrix von mises-fisher 3x2` | 0.5 |

Each sample runs 10 Gibbs sweeps over two columns (20 conditional updates), so
the sample rate is dominated by the MCMC work rather than by a single draw.

## Validation

- `zig build distcheck` passes with the new block.
- `zig build wasi-report` passes end-to-end through Node WASI and ends with
  `profilelongcheck ok`, so the allocator-conditional Matrix vMF block runs on
  `wasm32-wasi-musl`.
- `zig build test --summary all` passes 858/858 tests with all documentation
  gates.
- `compare/results/core-rand-coverage.md` S4-M1306 row added.

## Next bar

SO(3) matrix Fisher sampling (square `p = k`), vector/SIMD directional
sampling, further long-run goodness-of-fit checks, or newly discovered core
gaps against local Rust `rand` / `rand_distr` evidence.
