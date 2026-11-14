# S4-M1563 Validate-All Refresh After S4-M1562

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1901/1901
tests with the binomial dispatch-region stream snapshots present:

- native `alea-tests` 937/937,
- WASI Node tests 937/937,
- native and WASI distcheck with the binomial fill parity gates, the
  small-mean binomial mean gates, the multinomial/beta-binomial empirical
  gates, the HIN 4e6-draw mean gate, the tightened 1e9-sample long-run gate,
  the noncentral-t quantile round-trips, the truncated-normal/uniform gates,
  the noncentral/GPD/SICS gates, hypergeometric variance gates, Poisson
  quantile gates, heavy-tail mean gates, Wishart gates, and long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 958/958 tests (native
937/937). The milestone is test-only: no production code, stream, or
benchmark changed.
