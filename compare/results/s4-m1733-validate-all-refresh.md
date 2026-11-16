# S4-M1733 Validate-All Refresh After S4-M1731/S4-M1732

Date: 2026-11-16

`zig build validate-all --summary all` passes 124/124 steps and 1949/1949
tests with the Wrapped Normal distribution and the non-dyadic binomial gate
merge present:

- native `alea-tests` 961/961 (10 new Wrapped Normal tests),
- WASI Node tests 961/961 (the wrapped normal implementation and tests run on
  wasm32-wasi),
- native and WASI distcheck with the continuous/tail/copula gates, the GEV
  and von Mises sampler/CDF gates, the scalar/vector binned chi-square gates
  including the six dyadic vector geometric pmf gates and the five dyadic
  vector binomial gates, the fair/non-dyadic binomial gates, the
  large/extreme vector binomial CDF gates, the `fillBinomial(1000, 0.012)`
  and `fillBinomial(10000, 0.01)` CDF gates, the Zipf fill/sample and vector
  Zipf CDF gates, the vector hypergeometric and `fillHypergeometric(100, 30,
  10)` CDF gates, the `fillPoisson(4)` and `fillPoisson(20)` CDF gates, the
  new scalar/vector wrapped normal binned gates, the negative-binomial
  CDF/mean gates, the zeta and vector zeta CDF gates, the vector/scalar
  Poisson CDF gates, the discrete inversion, Poisson huge-lambda, noncentral-t,
  binomial walk, HIN, tightened 1e9 long-run, truncated-normal/uniform,
  noncentral/GPD/SICS, hypergeometric variance, heavy-tail mean, Wishart, and
  long-run gates,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

The independent long-run evidence is
`compare/results/s4-m1723-1e9-long-run-refresh.md` (1e9); the S4-M1731
`--long 10000000` run covers the new wrapped normal gates and the S4-M1732
low-count bin merge.
