# S4-M1301 — Directional benchmark rows: vMF and Watson

## Goal

Complete the advanced directional benchmark matrix. Bingham and Kent already
had fixed-seed rows, but the Von Mises-Fisher and Watson distributions added in
S4-M1251/S4-M1252 had no benchmark coverage. This also gives a baseline for
judging the Kent sampler cost.

## Changes

- `benchVonMisesFisher` adds the `alea von mises-fisher 3d` row with
  `κ = 5` and mean direction `[0, 0, 1]`.
- `benchWatson` adds the `alea watson 3d` row with `κ = 5` and mean axis
  `[0, 0, 1]`.
- Both follow the existing 3-trial fixed-seed checksum harness and are invoked
  from the `advanced multivariate throughput` section.

## Evidence

Command: `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216 "<filter>"`

| Row | M samples/s |
| --- | ---: |
| `alea von mises-fisher 3d` | 21.1 |
| `alea watson 3d` | 15.7 |
| `alea kent 3d` (S4-M1300 reference) | 14.4 |

The directional family now has comparable rows: vMF uses Wood rejection alone,
Watson adds a Beta rejection for the axial cosine, and Kent adds the
`I₀`-weighted marginal acceptance plus a conditional von Mises angle.

## Validation

- `zig fmt --check bench/throughput.zig` passes.
- `zig build test --summary all` passes 852/852 tests with all documentation
  gates.
- `compare/results/core-rand-coverage.md` S4-M1301 row added.

## Next bar

Matrix von Mises-Fisher, vector/SIMD copula/Bingham/Kent sampling, longer
statistical validation runs, or newly discovered core gaps against local Rust
`rand` / `rand_distr` evidence.
