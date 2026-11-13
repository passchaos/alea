# S4-M1293 — Multivariate Student-t integration: docs, distcheck, benchmark

## Goal

Integrate the S4-M1292 `MultivariateT(T)` addition into the surrounding
product surface:

- README and core-guide discovery.
- `tools/distcheck.zig` statistical gate.
- `bench/throughput.zig` throughput row.

## Changes

### Documentation

- README's distribution list now names `MultivariateT(T)` and
  `multi.MultivariateT`, alongside the existing multivariate normal and
  matrix-variate families.
- `docs/core-guide.md` describes the allocator-backed multivariate Student-t
  and its shared chi-squared scale.

### Distcheck

`checkAdvancedMultivariate` gains an allocator-backed `MultivariateT` block:

- target-conditional allocator (`wasm_allocator` on WASI, `smp_allocator`
  natively),
- 2D identity-scale, `ν = 5` sampler,
- 20,000-sample mean in `[-0.05, 0.05]`,
- 20,000-sample variance in `[1.5, 1.85]`,
- `varianceAt(0)` accessor in `[1.666, 1.667]`.

### Benchmark

`benchMultivariateT` follows the existing 3-trial fixed-seed checksum harness
and is invoked from the `advanced multivariate throughput` section as
`alea multivariate t 3d`.

## Evidence

Command: `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216 "multivariate t"`

| Row | M samples/s |
| --- | ---: |
| `alea multivariate t 3d` | 93.3 |

## Validation

- `zig build distcheck` passes with the new MultivariateT block.
- `zig build wasi-report` passes end-to-end through Node WASI and ends with
  `profilelongcheck ok`, so the allocator-conditional MultivariateT check also
  runs on `wasm32-wasi-musl`.
- `zig build test` passes 839/839 tests with all documentation gates.
- `compare/results/core-rand-coverage.md` S4-M1293 row added.

## Notes

- The benchmark uses the allocator-backed sampler with `sampleInto`, so it
  measures the transform and shared-scale cost rather than allocation.
- The distcheck block uses the same target-conditional allocator policy as the
  S4-M1282 WASI report fix.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
