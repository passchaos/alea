# S4-M1601 Validate-All Refresh After S4-M1600

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1927/1927
tests with the Generalized Extreme Value distribution present:

- native `alea-tests` 950/950,
- WASI Node tests 950/950 (both include the new GEV constructor, moments,
  Gumbel-equivalence, round-trip, support/Monte Carlo, free-function/fill,
  and f64x4/f32x8 vector tests, so the scalar and vector GEV paths compile
  and run on wasm32-wasi),
- native and WASI distcheck with the new GEV quantile round-trip grid and
  100k-sample mean gate, the von Mises sampler/CDF gate, the six-family
  discrete inversion gates, the Poisson huge-lambda inversion gates, the
  noncentral-t quantile round-trips, the binomial walk CDF/mean/variance
  gate, the HIN 4e6-draw mean gate, the tightened 1e9-sample long-run gate,
  the truncated-normal/uniform gates, the noncentral/GPD/SICS gates,
  hypergeometric variance gates, heavy-tail mean gates, Wishart gates, and
  long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test distcheck --summary all` independently passes 971/971 tests
(native 950/950). The milestone is additive: no existing sampling stream,
benchmark, or behavior changed.
