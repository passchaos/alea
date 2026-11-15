# S4-M1676 Validate-All Refresh After S4-M1675

Date: 2026-11-16

`zig build validate-all --summary all` passes 124/124 steps and 1927/1927
tests with the dense f64 vector zeta kernel present:

- native `alea-tests` 950/950,
- WASI Node tests 950/950 (the dense zeta path runs on wasm32-wasi),
- native and WASI distcheck with the continuous/tail/copula gates, the GEV
  and von Mises sampler/CDF gates, the scalar/vector binned chi-square gates
  including the fair/dyadic/non-dyadic binomial and geometric pmf gates, the
  negative-binomial CDF/mean gates, the `Zeta(1.25)`, `Zeta(1.5)`, `Zeta(2)`,
  `Zeta(2.5)`, and `Zeta(4)` CDF gates, the new `VectorZeta(f64x4)` CDF gates
  at `1`, `2`, and `4`, the discrete inversion, Poisson huge-lambda,
  noncentral-t, binomial walk, HIN, tightened 1e9 long-run,
  truncated-normal/uniform, noncentral/GPD/SICS, hypergeometric variance,
  heavy-tail mean, Wishart, and long-run gates,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test distcheck statcheck --summary all` independently passes 39/39
steps and 973/973 tests (native 950/950).
