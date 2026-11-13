# S4-M1321 — 10,000,000-sample long-run validation

## Goal

Push the opt-in `distcheck --long` mode beyond the default 1,000,000 samples
and record 10,000,000-sample evidence for the core scalar, multivariate,
directional, matrix, and SIMD families.

## Evidence

Command:
`zig build -Doptimize=ReleaseFast distcheck -- --long 10000000`

Output:

```
long tails: normal=0.002714 exponential=0.049740 student-t=0.030199 (expected 0.030099)
long copula 1% joint lower-tail rates: gaussian=0.001869 student-t=0.003957
distlongcheck ok (10000000 samples)
```

The run covers the normal/exponential/Poisson/Gamma moments, multivariate
normal/Student-t/skew-normal, Kent, Bingham, von Mises-Fisher, exact SO(3)
matrix Fisher, SIMD vMF lane moments, and the 100,000-sample Gibbs matrix
Langevin marginal gates, followed by the tail and copula checks.

Observed tail rates remain within their expected bands:

- normal `P(|X| > 3)` = 0.002714 (expected 0.0026998),
- exponential `P(X > 3)` = 0.049740 (expected 0.049787),
- Student-t(5) `P(|T| > 3)` = 0.030199 (expected 0.030099),
- t-copula 1% joint lower-tail rate = 0.003957 vs Gaussian 0.001869
  (2.12×).

The tool run itself takes about 16 seconds in `ReleaseFast`; the remaining
wall time in the recorded run was the shared Zig build slot wait.

## Changes

- `docs/tooling.md` documents the `zig build distcheck -- --long [samples]`
  opt-in and its default.

## Validation

- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- The default `zig build distcheck` remains green.
- `compare/results/core-rand-coverage.md` S4-M1321 row added.

## Next bar

O(3) matrix Fisher reflections, further vector compaction/squeeze
optimizations, broader platform runners, or newly discovered core gaps.
