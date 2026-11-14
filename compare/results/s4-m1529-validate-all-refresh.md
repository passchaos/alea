# S4-M1529 Validate-All Refresh After S4-M1528

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1867/1867
tests with the 64-bit discrete quantile search and the huge-lambda Poisson
gates present:

- native `alea-tests` 920/920,
- WASI Node tests 920/920,
- WASI distcheck with the `poisson huge quantile` gates (previously NaN on
  wasm32),
- native distcheck (heavy-tail mean gates, Wishart gates, and long-run
  blocks), distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 939/939 tests (native
920/920). No RNG stream changed in this milestone.
