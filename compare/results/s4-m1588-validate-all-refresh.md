# S4-M1588 Validate-All Refresh After S4-M1586/S4-M1587

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1911/1911
tests with the scalar-per-lane vector vMF and the vector Kent uniform-angle
branch present:

- native `alea-tests` 942/942,
- WASI Node tests 942/942,
- native and WASI distcheck with the empirical vMF mean-resultant, Kent
  mean-resultant/major/minor variance, and matrix-vMF first-column gates, the
  six-family discrete inversion gates, the Poisson huge-lambda inversion
  gates, the noncentral-t quantile round-trips, the binomial walk
  CDF/mean/variance gate, the HIN 4e6-draw mean gate, the tightened
  1e9-sample long-run gate, the truncated-normal/uniform gates, the
  noncentral/GPD/SICS gates, hypergeometric variance gates, heavy-tail mean
  gates, Wishart gates, and long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test distcheck --summary all` independently passes 963/963 tests
(native 942/942). The vector vMF and vector Kent streams changed deliberately
(recorded in `reproducibility-matrix.md`); the scalar vMF/Kent rows, the
Watson/Bingham rows, and the Bingham/Watson checksums are unchanged.
