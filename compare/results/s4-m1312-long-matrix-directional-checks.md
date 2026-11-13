# S4-M1312 — Long-run matrix and SIMD directional checks

## Goal

Extend the 1,000,000-sample `distcheck --long` mode to the newest matrix and
SIMD directional families so their samplers are validated at the same scale as
the core scalar distributions.

## Changes

`checkLongRun` now adds:

- **Exact SO(3) matrix Fisher** with `F = 2I`: 1,000,000 rotations; the mean
  trace must match the exact S³ Bingham moment computed by numerical
  integration within `±0.004`.
- **SIMD von Mises-Fisher** `f64x4` with `κ = 5`: 1,000,000 lane samples; the
  lane mean `z` must match the scalar vMF mean resultant within `±0.003`.
- **Gibbs matrix Langevin** on V_{2,3} with a zero second column: 100,000
  samples after burn-in 100 / thinning 10; the first-column mean `z` must
  match the vMF mean resultant within `±0.02`, and the second-column means
  must be zero within `±0.02`.

The existing normal/exponential/Poisson/Gamma/multivariate/tail/copula gates
are unchanged.

## Evidence

Command:
`zig build -Doptimize=ReleaseFast distcheck -- --long 1000000`

Output:

```
long tails: normal=0.002705 exponential=0.050055 student-t=0.030252 (expected 0.030099)
long copula 1% joint lower-tail rates: gaussian=0.001869 student-t=0.003946
distlongcheck ok (1000000 samples)
```

All new matrix/SIMD gates pass at the default 1,000,000-sample setting.

## Validation

- `zig build -Doptimize=ReleaseFast distcheck -- --long 1000000` passes.
- `zig build test --summary all` passes 867/867 tests with all documentation
  gates.
- `zig fmt --check tools/distcheck.zig` passes.
- `compare/results/core-rand-coverage.md` S4-M1312 row added.

## Next bar

SIMD Kent/Watson/Bingham sampling, further long-run tail/correlation checks,
or newly discovered core gaps against local Rust `rand` / `rand_distr`
evidence.
