# S4-M1304 — Long-run tail and copula-dependence checks

## Goal

Extend the S4-M1302 `distcheck --long` mode beyond moment recovery with tail
probabilities and copula dependence checks, so the 1,000,000-sample run also
validates distribution shape and dependence rather than only means and
covariances.

## Changes

`checkLongRun` now adds:

- **Tail probabilities** at 1,000,000 samples:
  - standard normal `P(|X| > 3)` vs `0.0026998`,
  - standard exponential `P(X > 3)` vs `e⁻³ = 0.049787`,
  - Student-t(5) `P(|T| > 3)` vs `2·(1 − F₅(3))` from `studentTCdf`.
- **Gaussian copula correlation** with `ρ = 0.6`, recovered through probit
  coordinates.
- **Student-t copula lower-tail dependence** with `ν = 3`, `ρ = 0.6`: the 1%
  joint lower-tail rate must exceed 1.5× the Gaussian copula rate. This is a
  qualitative gate for the positive tail dependence that distinguishes the
  t-copula from the Gaussian copula.

## Evidence

Command:
`zig build -Doptimize=ReleaseFast distcheck -- --long 1000000`

Observed output:

```
long tails: normal=0.002705 exponential=0.050055 student-t=0.030252 (expected 0.030099)
long copula 1% joint lower-tail rates: gaussian=0.001869 student-t=0.003946
distlongcheck ok (1000000 samples)
```

The t-copula joint lower-tail rate is 2.11× the Gaussian rate, matching the
expected positive tail dependence. All moment checks from S4-M1302 still pass.

## Validation

- `zig build -Doptimize=ReleaseFast distcheck -- --long 1000000` passes.
- `zig build test --summary all` passes 853/853 tests with all documentation
  gates.
- `zig fmt --check tools/distcheck.zig` passes.
- `compare/results/core-rand-coverage.md` S4-M1304 row added.

## Next bar

Matrix von Mises-Fisher, vector/SIMD copula/Bingham/Kent sampling, further
long-run goodness-of-fit checks, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
