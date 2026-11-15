# S4-M1641 Validate-All Refresh After S4-M1640

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1927/1927
tests with the large-trial vector binomial dyadic path present:

- native `alea-tests` 950/950,
- WASI Node tests 950/950 (the large-trial kernel runs on wasm32-wasi),
- native and WASI distcheck with the continuous/tail/copula gates, the GEV
  and von Mises sampler/CDF gates, the scalar/vector binned chi-square gates
  including the vector binomial pmf gate, the discrete inversion, Poisson
  huge-lambda, noncentral-t, binomial walk, HIN, tightened 1e9 long-run,
  truncated-normal/uniform, noncentral/GPD/SICS, hypergeometric variance,
  heavy-tail mean, Wishart, and long-run gates,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test distcheck statcheck --summary all` independently passes 39/39
steps and 973/973 tests (native 950/950). The large-trial vector stream
change (S4-M1640) is versioned in `compare/results/reproducibility-matrix.md`.
