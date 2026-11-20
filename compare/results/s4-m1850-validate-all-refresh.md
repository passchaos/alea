# S4-M1850 Validate-All Refresh After the Tail and Start Optimizations

Date: 2026-11-20

`zig build validate-all --summary all` passes 124/124 steps and 1981/1981
tests, including native `alea-tests` 977/977 and WASI Node tests 977/977.

The run covers the S4-M1839..M1849 changes: the four-term shorter von Mises
Fourier series, the ex-Gaussian bracket skip, the moment-matched skew starts,
the deep-tail E1 skip and its tighter threshold, the wrapped pre-step gate,
the density-CDF-from-density rewrite, the Rice and Hoyt linear lower-tail
starts, the inverse-Gaussian and ex-Gaussian CDF noise floor, the 20-point
Owen rule in both skew CDFs, the gamma/Rice/Hoyt bracket skips, and the
asymptotic von Mises ratio start.

The run includes:

- native and WASI unit suites (including the wrapped and plain skew inverse
  tests, the von Mises inverse tests, the Rice/Hoyt/inverse-Gaussian/
  ex-Gaussian round trips, and the gamma tail tests);
- native and WASI distcheck with the continuous/tail/copula gates, the
  scalar and vector binned chi-square gates, and the discrete CDF gates;
- distcheck-libc, statcheck, profilecheck (long/stress/tail), the PractRand
  self-test, the six crosscheck targets, and the chained WASI report.

No library code changed in this milestone.

## Validation

- `zig build validate-all --summary all`: 124/124 steps, 1981/1981 tests.

## Next Bar

Keep the no-known-gaps and long-run evidence current. The wrapped
skew-normal quantile remains the slowest Alea-only row (about 2.3M
quantiles/s) and the large-hypergeometric rows (0.86-0.87x) the only
sub-parity comparable workloads.
