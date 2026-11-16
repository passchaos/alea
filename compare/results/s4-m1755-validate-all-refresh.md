# S4-M1755 Validate-All Refresh After S4-M1754

Date: 2026-11-16

`zig build validate-all --summary all` passes 124/124 steps and 1955/1955
tests with the Marcum P1 recurrence fast path present:

- native `alea-tests` 964/964 (including the new recurrence comparison test),
- WASI Node tests 964/964 (the fast path runs on wasm32-wasi),
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
`compare/results/s4-m1751-1e9-long-run-refresh.md`; the recurrence fast path
is stream-preserving and does not affect sampling or the CDF gates.
