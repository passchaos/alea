# S4-M1559 Validate-All Refresh After S4-M1558

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1899/1899
tests with the direct-source one-setup HIN fill present:

- native `alea-tests` 936/936,
- WASI Node tests 936/936,
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

`zig build test --summary all` independently passes 957/957 tests (native
936/936). The change is stream-preserving: the facade and direct-source fill
rows keep the identical checksum, and no sampling stream changed.
