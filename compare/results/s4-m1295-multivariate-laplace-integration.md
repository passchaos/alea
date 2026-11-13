# S4-M1295 — Multivariate Laplace integration: docs, distcheck, benchmark

## Goal

Integrate the S4-M1294 `MultivariateLaplace(T)` addition into the surrounding
product surface:

- README and core-guide discovery.
- `tools/distcheck.zig` statistical gate.
- `bench/throughput.zig` throughput row.

## Changes

### Documentation

- README's distribution list now names `MultivariateLaplace(T)` and
  `multi.MultivariateLaplace`, alongside the multivariate normal/Student-t
  families.
- `docs/core-guide.md` describes the exponential scale mixture.

### Distcheck

`checkAdvancedMultivariate` gains an allocator-backed `MultivariateLaplace`
block:

- target-conditional allocator (`wasm_allocator` on WASI, `smp_allocator`
  natively),
- 2D identity-scale sampler,
- 40,000-sample mean in `[-0.05, 0.05]`,
- 40,000-sample variance in `[0.88, 1.12]`,
- `varianceAt(0)` accessor in `[0.999, 1.001]`.

### Benchmark

`benchMultivariateLaplace` follows the existing 3-trial fixed-seed checksum
harness and is invoked from the `advanced multivariate throughput` section as
`alea multivariate laplace 3d`.

## Evidence

Command: `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216 "multivariate laplace"`

| Row | M samples/s |
| --- | ---: |
| `alea multivariate laplace 3d` | 90.2 |

## Validation

- `zig build distcheck` passes with the new MultivariateLaplace block.
- `zig build wasi-report` passes end-to-end through Node WASI and ends with
  `profilelongcheck ok`, so the allocator-conditional Laplace check also runs
  on `wasm32-wasi-musl`.
- `zig build test` passes 842/842 tests with all documentation gates.
- `compare/results/core-rand-coverage.md` S4-M1295 row added.

## Notes

- The benchmark uses the allocator-backed sampler with `sampleInto`, so it
  measures the transform and exponential-scale cost rather than allocation.
- The distcheck block uses the same target-conditional allocator policy as the
  S4-M1282 WASI report fix.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
