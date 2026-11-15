# S4-M1629 Validate-All Refresh After S4-M1628

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1927/1927
tests with the `exp2`/`log2` transforms in the Weibull, Fréchet, GEV, and
log-logistic samplers:

- native `alea-tests` 950/950,
- WASI Node tests 950/950 (the four changed scalar samplers run on
  wasm32-wasi),
- native and WASI distcheck with the continuous/tail/copula gates, the GEV
  and von Mises sampler/CDF gates, the six vector binned chi-square gates,
  the scalar binned chi-square gates, the six-family discrete inversion
  gates, the Poisson huge-lambda inversion gates, the noncentral-t quantile
  round-trips, the binomial walk CDF/mean/variance gate, the HIN 4e6-draw
  mean gate, the tightened 1e9-sample long-run gate, the truncated-normal/
  uniform gates, the noncentral/GPD/SICS gates, hypergeometric variance
  gates, heavy-tail mean gates, Wishart gates, and long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test distcheck statcheck --summary all` independently passes 39/39
steps and 973/973 tests (native 950/950). The four ulp-level scalar stream
changes (S4-M1628) are versioned in
`compare/results/reproducibility-matrix.md`.
