# S4-M1759 Validate-All Refresh After S4-M1758

Date: 2026-11-16

`zig build validate-all --summary all` passes 124/124 steps and 1971/1971
tests with the Wrapped Skew-Normal distribution present:

- native `alea-tests` 972/972 (including the 9 new Wrapped Skew-Normal tests),
- WASI Node tests 972/972 (the new distribution and tests run on
  wasm32-wasi),
- native and WASI distcheck with the continuous/tail/copula gates, the GEV
  and von Mises sampler/CDF gates, the scalar/vector binned chi-square gates
  including the six dyadic vector geometric pmf gates and the five dyadic
  vector binomial gates, the fair/non-dyadic binomial gates, the
  large/extreme vector binomial CDF gates, the `fillBinomial(1000, 0.012)`
  and `fillBinomial(10000, 0.01)` CDF gates, the Zipf fill/sample and vector
  Zipf CDF gates, the vector hypergeometric and `fillHypergeometric(100, 30,
  10)` CDF gates, the `fillPoisson(4)` and `fillPoisson(20)` CDF gates, the
  scalar/vector wrapped normal binned gates, the negative-binomial CDF/mean
  gates, the zeta and vector zeta CDF gates, the vector/scalar Poisson CDF
  gates, the discrete inversion, Poisson huge-lambda, noncentral-t, binomial
  walk, HIN, tightened 1e9 long-run, truncated-normal/uniform,
  noncentral/GPD/SICS, hypergeometric variance, heavy-tail mean, Wishart, and
  long-run gates,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

The independent 1e9 evidence is
`compare/results/s4-m1757-1e9-long-run-refresh.md`; the new distribution's
long binned gates are exercised by the S4-M1760 1e7 run.
