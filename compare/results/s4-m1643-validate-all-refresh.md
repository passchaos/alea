# S4-M1643 Validate-All Refresh After S4-M1642

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1927/1927
tests with the vectorized dyadic geometric kernels present:

- native `alea-tests` 950/950,
- WASI Node tests 950/950 (the `VectorGeometric`/`VectorGeometricFailures`
  kernels run on wasm32-wasi),
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

A first run reported 10 transient example-compile failures while another
session was building concurrently; a clean re-run of the same tree passes
124/124 steps with all example steps succeeding. The vector geometric stream
change (S4-M1642) is versioned in `compare/results/reproducibility-matrix.md`.
