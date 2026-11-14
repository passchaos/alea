# S4-M1551 Validate-All Refresh After S4-M1550

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1897/1897
tests with the HIN left-envelope correction present:

- native `alea-tests` 935/935,
- WASI Node tests 935/935,
- native and WASI distcheck with the new 4e6-draw
  `binomial(1e18, 2e-17)` mean gate, the tightened 1e9-sample long-run
  gate, the noncentral-t quantile round-trips, the truncated-normal/uniform
  gates, the noncentral/GPD/SICS gates, hypergeometric variance gates,
  Poisson quantile gates, heavy-tail mean gates, Wishart gates, and
  long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 954/954 tests (native
935/935). The HIN small-`p` draw stream changed deliberately; all other
sampling streams are unchanged.
