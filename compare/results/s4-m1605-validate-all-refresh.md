# S4-M1605 Validate-All Refresh After S4-M1604

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1927/1927
tests with the scalar Kent `log I₀` series present:

- native `alea-tests` 950/950,
- WASI Node tests 950/950,
- native and WASI distcheck with the Kent mean-resultant and
  major/minor-variance gates, the GEV and von Mises gates, the six-family
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
(native 950/950). The change is acceptance-precision-only: the recorded
benchmark checksum is unchanged, and `reproducibility-matrix.md` records the
versioned precision.
