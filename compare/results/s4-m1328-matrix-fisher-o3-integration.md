# S4-M1328 — Matrix Fisher O(3) integration: distcheck and benchmark

## Goal

Integrate the S4-M1327 `MatrixFisherO3(T)` addition into the validation and
benchmark surface.

## Changes

### Distcheck

`checkAdvancedMultivariate` gains an `F = 2I` Matrix Fisher O(3) block:

- the computed SO(3) mixture weight must match the exact 1D integral
  `Z_SO/(Z_SO+Z_ref)` within `1e-3`,
- 20,000 samples' positive-determinant frequency must match that weight
  within `±0.03`,
- the block runs under `wasm32-wasi` through `zig build wasi-report`.

### Benchmark

`benchMatrixFisherO3` follows the existing 3-trial fixed-seed checksum harness
and is invoked from the `advanced multivariate throughput` section as
`alea matrix fisher o3`, using a general 3×3 parameter.

## Evidence

Command:
`zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216 "matrix fisher"`

| Row | M samples/s |
| --- | ---: |
| `alea matrix fisher so3` | 24.7 |
| `alea matrix fisher o3` | 17.8 |

The O(3) sampler is slower because each sample performs a component selection
plus one Bingham draw, and the construction also computes the deterministic
mixture weights; the timed loop contains only sampling.

## Validation

- `zig build distcheck` passes with the new block.
- `zig build wasi-report` passes end-to-end and ends with `profilelongcheck ok`.
- `zig build test --summary all` passes 884/884 tests with all documentation
  gates.
- `compare/results/core-rand-coverage.md` S4-M1328 row added.

## Next bar

Further vector compaction/squeeze optimizations, broader platform runners, or
newly discovered core gaps.
