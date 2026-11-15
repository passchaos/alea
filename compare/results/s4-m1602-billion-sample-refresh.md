# S4-M1602 Billion-Sample Refresh With the GEV and von Mises Gates

Date: 2026-11-15

## Run

Added a `--long` gate for the new Generalized Extreme Value sampler
(`μ = 1`, `σ = 2`, `ξ = 0.3`): the sample mean against the analytic
`2.987035550983718` with the standard-error-scaled tolerance (`9.2e-4` at
1e9), and the empirical `cdf(3.0)` against the analytic `0.659...` with a
6-SE tolerance (`9.0e-5` at 1e9). The existing von Mises CDF gate
(S4-M1598) and the standard-error-scaled directional gates (S4-M1594) run in
the same sweep.

Rebuilt the ReleaseFast `alea-distcheck` from the current tree and ran it
directly:

```
./.zig-cache/o/4d4d70004d5783d1600135fe641b1361/alea-distcheck --long 1000000000
```

The run takes about 25 minutes and prints
`distlongcheck ok (1000000000 samples)`.

## Result

All gates pass at 1e9 samples, including:

- the GEV mean and `cdf(3.0)` gates at their 6-SE tolerances;
- the von Mises sampler/CDF gate (`μ = 0.4`, `κ = 5`, `x = −1`);
- the tightened Kent/vMF/vector-vMF/Watson/Bingham/vector-Kent directional
  moment gates (`9.49e-5` for `[0,1]` quantities, down from `0.003`).

The non-directional values reproduce S4-M1594/S4-M1589:
`binomial(4)=0.237505`, `gamma(3)=0.450579`, normal tail `0.002698`,
student-t tail `0.030104`, Gaussian copula `0.001875`, huge hypergeometric
`below=0.252478 (cdf 0.252492)`.

## Validation

- Tooling-only change: the GEV long gate is new; no library code, sampling
  stream, public API, or benchmark changed.
- The default `distcheck` and the 1e7 long mode pass before the 1e9 run.
- The next full `validate-all` refresh compiles the new gate on native and
  WASI.
