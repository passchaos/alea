# S4-M1625 Validate-All Refresh After S4-M1624

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1927/1927
tests with the scalar-per-lane vector SkewNormal, InverseGaussian, and
Maxwell samplers and the eight new vector benchmark rows present:

- native `alea-tests` 950/950,
- WASI Node tests 950/950 (the three changed vector samplers and the updated
  inverse-gaussian infinity stream-shape test run on wasm32-wasi),
- native and WASI distcheck with the continuous/tail/copula gates, the GEV
  and von Mises sampler/CDF gates, the binned chi-square long-run gates, the
  six-family discrete inversion gates, the Poisson huge-lambda inversion
  gates, the noncentral-t quantile round-trips, the binomial walk
  CDF/mean/variance gate, the HIN 4e6-draw mean gate, the tightened
  1e9-sample long-run gate, the truncated-normal/uniform gates, the
  noncentral/GPD/SICS gates, hypergeometric variance gates, heavy-tail mean
  gates, Wishart gates, and long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test distcheck statcheck --summary all` independently passes 39/39
steps and 973/973 tests (native 950/950). The three vector stream changes
(S4-M1624) are versioned in `compare/results/reproducibility-matrix.md`;
PERT, normal-inverse-Gaussian, triangular, arcsine, and log-normal keep their
previous streams.
