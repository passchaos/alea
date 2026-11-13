# S4-M1299 — Kent integration: docs, distcheck, benchmark

## Goal

Integrate the S4-M1298 `Kent(T)` addition into the surrounding product
surface:

- README and core-guide discovery.
- `tools/distcheck.zig` statistical gate.
- `bench/throughput.zig` throughput row.

## Changes

### Documentation

- README's distribution list now names `Kent` alongside the von Mises-Fisher,
  Watson, and Bingham directional families.
- `docs/core-guide.md` describes the Fisher-Bingham F5 density, the
  `0 ≤ β < κ/2` parameter constraint, the mean-matched vMF rejection sampler,
  the `β = 0` reduction, and the deterministic-quadrature moment diagnostics.

### Distcheck

`checkAdvancedMultivariate` gains a `Kent` block with `κ = 5`, `β = 1.5`,
mean direction `[0, 0, 1]`, and major axis `[1, 0, 0]`:

- every sample is checked for unit norm within `1e-9`,
- 40,000-sample mean resultant (`z` component) within `±0.03` of the
  quadrature accessor,
- 40,000-sample γ₂ and γ₃ variances within `±0.03` of `varianceAt`,
- the γ₂ variance must exceed the γ₃ variance (ovalness anisotropy),
- the covariance trace must equal `varianceValue()` within `1e-9`.

### Benchmark

`benchKent` follows the existing 3-trial fixed-seed checksum harness and is
invoked from the `advanced multivariate throughput` section as
`alea kent 3d`, using `κ = 5`, `β = 1.5`, mean `[0, 0, 1]`, and major axis
`[1, 0, 0]`.

## Evidence

Command: `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216 "kent"`

| Row | M samples/s |
| --- | ---: |
| `alea kent 3d` | 10.0 |

The lower throughput than vMF/Bingham reflects the exact rejection sampler:
each accepted point uses a mean-matched vMF proposal and a `β`-dependent
acceptance test.

## Validation

- `zig build distcheck` passes with the new Kent block.
- `zig build wasi-report` passes end-to-end through Node WASI and ends with
  `profilelongcheck ok`.
- `zig build test --summary all` passes 852/852 tests with all documentation
  gates.
- `compare/results/core-rand-coverage.md` S4-M1299 row added.

## Notes

- The distcheck gate compares two independent code paths: rejection sampling
  for the moments versus adaptive Simpson quadrature for the accessors.
- The sampler uses `sample` (allocating none) on the stack-allocated 3D value
  type, so the benchmark measures the rejection loop rather than allocation.

## Next bar

Matrix von Mises-Fisher, vector/SIMD copula/Bingham/Kent sampling, longer
statistical validation runs, or newly discovered core gaps against local Rust
`rand` / `rand_distr` evidence.
