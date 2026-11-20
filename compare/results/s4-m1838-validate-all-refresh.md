# S4-M1838 Validate-All Refresh After the Quantile Start and Tail Work

Date: 2026-11-20

`zig build validate-all --summary all` passes 124/124 steps and 1981/1981
tests, including native `alea-tests` 977/977 and WASI Node tests 977/977.

The run covers the S4-M1828..M1837 changes: the Owen rule-noise floor in
the skew quantile stop tests, the cached Owen geometry in the wrapped
quantile start, the von Mises ratio-table init multiply and the four-step
shorter recurrence, the wrapped quantile trust-region start, the
moment-matched start for both skew-normal quantiles, the deep lower-tail E1
skip in the upper-tail wrappers, the pre-step wrap-mass gate, the
ex-Gaussian bracket skip, and the no-known-gaps refresh.

The run includes:

- native and WASI unit suites (including the wrapped quantile inverse
  tests, the von Mises inverse tests, and the ex-Gaussian and gamma tail
  tests);
- native and WASI distcheck with the continuous/tail/copula gates, the
  scalar and vector binned chi-square gates, and the discrete CDF gates;
- distcheck-libc, statcheck, profilecheck (long/stress/tail), the PractRand
  self-test, the six crosscheck targets, and the chained WASI report.

No library code changed in this milestone.

## Validation

- `zig build validate-all --summary all`: 124/124 steps, 1981/1981 tests.

## Next Bar

Keep the no-known-gaps and long-run evidence current. The wrapped
skew-normal quantile remains the slowest Alea-only row at about 1.3-1.5M
quantiles/s; the large-hypergeometric codegen gap (0.86-0.87x) is still the
only sub-parity comparable workload.
