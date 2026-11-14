# S4-M1543 Validate-All Refresh After S4-M1542

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1883/1883
tests with the GPD/SICS diagnostics and the gamma upper-tail refinement
present:

- native `alea-tests` 928/928,
- WASI Node tests 928/928,
- native and WASI distcheck with the new generalized-Pareto and
  scaled-inverse-chi-squared quantile round-trips plus the hypergeometric
  variance gates, Poisson quantile gates, heavy-tail mean gates, Wishart
  gates, and long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 947/947 tests (native
928/928). Sampling streams are unchanged; the new helpers and the gamma
upper-tail refinement are deterministic diagnostics.
