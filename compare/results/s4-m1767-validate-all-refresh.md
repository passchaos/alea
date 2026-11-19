# S4-M1767 Validate-All Refresh After the Quantile Recurrence Work

Date: 2026-11-20

`zig build validate-all --summary all` passes 124/124 steps and 1979/1979
tests, including native `alea-tests` 976/976 and WASI Node tests 976/976.

The run covers the S4-M1761..M1766 changes:

- the `LogNormalFastExp` inlined-exponential profile and its 1-ULP accuracy
  tests;
- the wrapped skew-normal and wrapped normal CDF/quantile image caches and
  saturated-tail skips;
- the Student-t integer-degree quantile, the Hoyt gamma recurrence, the
  FisherF/beta/PERT integer-shape recurrences, and the von Mises Bessel-ratio
  cache, plus the new quantile round-trip tests;
- native and WASI distcheck with the continuous/tail/copula gates, the scalar
  and vector binned chi-square gates, the Poisson/binomial/hypergeometric/Zipf
  CDF gates, the long-run gates, distcheck-libc, statcheck, profilecheck
  (including the long/stress/tail variants), the PractRand self-test, the six
  crosscheck targets, and the chained WASI report.

No library code changed in this milestone; it records the aggregate evidence
after the performance work. The independent 1e9 long-run evidence predates the
new quantile tests and is tracked by the next long-run refresh.

## Rejected optimization attempts this turn

Recorded in `compare/results/performance-triage.md`:

- replacing the libm `@exp` in the Owen T integrand with the inlined
  `fastExp64` kernel regressed the skew-normal CDF by about 20% and the
  wrapped skew-normal CDF/quantile by 17-19% with unchanged checksums;
- routing the skew-normal far tail (`z >= 6`) through `normUpperTailF64`
  instead of the incomplete-gamma continued fraction was neutral and was
  reverted; `std.math.erfc` is not available in Zig 0.16;
- routing `vectorPertFrom` through the per-lane scalar `pertFrom` changed the
  sampling stream (the reusable `Pert` sampler and the free function use
  different beta paths) for a 2.5% gain, so it was rejected.
