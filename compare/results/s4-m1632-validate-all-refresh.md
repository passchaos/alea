# S4-M1632 Validate-All Refresh After S4-M1631

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1927/1927
tests with the `exp2`/`log2` Weibull/Fréchet/log-logistic fill paths present:

- native `alea-tests` 950/950,
- WASI Node tests 950/950,
- native and WASI distcheck with the continuous/tail/copula gates, the GEV
  and von Mises sampler/CDF gates, the scalar and vector binned chi-square
  gates, the discrete inversion, Poisson huge-lambda, noncentral-t, binomial
  walk, HIN, tightened 1e9 long-run, truncated-normal/uniform,
  noncentral/GPD/SICS, hypergeometric variance, heavy-tail mean, Wishart, and
  long-run gates,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test distcheck statcheck --summary all` independently passes 39/39
steps and 973/973 tests (native 950/950). The fill stream changes
(S4-M1631) are versioned in `compare/results/reproducibility-matrix.md`.
