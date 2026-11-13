# S4-M1297 — Multivariate skew-normal integration: docs, distcheck, benchmark

## Goal

Integrate the S4-M1296 `MultivariateSkewNormal(T)` addition into the
surrounding product surface:

- README and core-guide discovery.
- `tools/distcheck.zig` statistical gate.
- `bench/throughput.zig` throughput row.

## Changes

### Documentation

- README's distribution list now names `MultivariateSkewNormal(T)` and
  `multi.MultivariateSkewNormal`, alongside the multivariate normal,
  Student-t, and Laplace families.
- `docs/core-guide.md` describes the shape-driven asymmetry.

### Distcheck

`checkAdvancedMultivariate` gains an allocator-backed
`MultivariateSkewNormal` block:

- target-conditional allocator (`wasm_allocator` on WASI, `smp_allocator`
  natively),
- 2D location `[0, 0]`, scale `[1, 0.5, 0.5, 2]`, shape `[2, -1]`,
- analytic targets from `δ = [1.5/√5, −1/√5]`:
  `E[X₀] = √(2/π)·δ₀` and `Var[X₀] = 1 − (2/π)·δ₀²`,
- 40,000-sample mean within `±0.03` of `E[X₀]`,
- 40,000-sample variance within `±0.06` of `Var[X₀]`,
- `varianceAt(0)` accessor within `1e-9` of the analytic variance.

### Benchmark

`benchMultivariateSkewNormal` follows the existing 3-trial fixed-seed
checksum harness and is invoked from the `advanced multivariate throughput`
section as `alea multivariate skew-normal 3d`. It uses the 3D scale matrix
shared with the Student-t/Laplace rows and shape `[2, -1, 0.5]`.

## Evidence

Command: `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216 "multivariate skew-normal"`

| Row | M samples/s |
| --- | ---: |
| `alea multivariate skew-normal 3d` | 100.1 |

## Validation

- `zig build distcheck` passes with the new MultivariateSkewNormal block.
- `zig build wasi-report` passes end-to-end through Node WASI and ends with
  `profilelongcheck ok`, so the allocator-conditional skew-normal check also
  runs on `wasm32-wasi-musl`.
- `zig build test` passes 846/846 tests with all documentation gates.
- `compare/results/core-rand-coverage.md` S4-M1297 row added.

## Notes

- The benchmark uses the allocator-backed sampler with `sampleInto`, so it
  measures the residual-normal transform, absolute normal draw, and shape
  addition rather than allocation.
- The distcheck block uses the same target-conditional allocator policy as the
  S4-M1282 WASI report fix.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
