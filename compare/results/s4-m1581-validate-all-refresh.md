# S4-M1581 Validate-All Refresh After S4-M1580

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1907/1907
tests with the vector Kent `log I₀` series present:

- native `alea-tests` 940/940,
- WASI Node tests 940/940,
- native and WASI distcheck with the six-family discrete inversion gates,
  the Poisson huge-lambda inversion gates, the noncentral-t quantile
  round-trips, the binomial walk CDF/mean/variance gate, the HIN 4e6-draw
  mean gate, the tightened 1e9-sample long-run gate, the
  truncated-normal/uniform gates, the noncentral/GPD/SICS gates,
  hypergeometric variance gates, heavy-tail mean gates, Wishart gates, and
  long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 961/961 tests (native
940/940). The vector Kent acceptance is a versioned stream for
`a <= 1.5` lanes (recorded in `reproducibility-matrix.md`); the benchmark
checksum is unchanged for the recorded parameters, and all other sampling
streams are unchanged.
