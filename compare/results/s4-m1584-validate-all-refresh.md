# S4-M1584 Validate-All Refresh After S4-M1583

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1911/1911
tests with the exact truncated-exponential vMF/Kent marginal present:

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
(native 942/942). The S² vMF, Kent, and single-column matrix-vMF streams
changed deliberately (recorded in `reproducibility-matrix.md`); the Bingham
and Watson checksums are unchanged, and `dim > 3` vMF keeps the Wood
rejection path.
