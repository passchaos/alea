# S4-M1672 Validate-All Refresh After S4-M1670/S4-M1671

Date: 2026-11-16

`zig build validate-all --summary all` passes 124/124 steps and 1927/1927
tests with the `Zeta(1.25)` inverse-CDF fix and the scalar small-`lambda`
Poisson coverage row present:

- native `alea-tests` 950/950,
- WASI Node tests 950/950 (the corrected `Zeta`/`VectorZeta` exponent-1.25
  path runs on wasm32-wasi),
- native and WASI distcheck with the continuous/tail/copula gates, the GEV
  and von Mises sampler/CDF gates, the scalar/vector binned chi-square gates
  including the fair/dyadic/non-dyadic binomial and geometric pmf gates, the
  negative-binomial CDF/mean gates, the new `Zeta(1.25)` CDF gates at `1`, `2`,
  and `4`, the discrete inversion, Poisson huge-lambda, noncentral-t, binomial
  walk, HIN, tightened 1e9 long-run, truncated-normal/uniform,
  noncentral/GPD/SICS, hypergeometric variance, heavy-tail mean, Wishart, and
  long-run gates,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test distcheck statcheck --summary all` independently passes 39/39
steps and 973/973 tests (native 950/950), and
`zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216
"poisson small"` runs the bench tests plus both small-`lambda` rows.
