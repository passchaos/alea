# S4-M1547 Validate-All Refresh After S4-M1546

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1893/1893
tests with the truncated-normal and Uniform CDF/quantile diagnostics
present:

- native `alea-tests` 933/933,
- WASI Node tests 933/933,
- native and WASI distcheck with the truncated-normal and uniform round-trip
  gates plus the noncentral/GPD/SICS gates, hypergeometric variance gates,
  Poisson quantile gates, heavy-tail mean gates, Wishart gates, and long-run
  blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 952/952 tests (native
933/933). Sampling streams are unchanged; the new helpers are deterministic
diagnostics.
