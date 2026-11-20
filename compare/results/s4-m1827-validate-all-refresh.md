# S4-M1827 Validate-All Refresh After the Gamma and Wrapped Optimizations

Date: 2026-11-20

`zig build validate-all --summary all` passes 124/124 steps and 1981/1981
tests, including native `alea-tests` 977/977 and WASI Node tests 977/977.

The run covers the S4-M1823..M1826 changes: the half-integer gamma CDF
recurrence, the saturated endpoint-term clamps in the wrapped skew-normal
CDF and quantile cache, the 20-point Owen T rule in the wrapped skew-normal
quantile cache, and the saturated endpoint-term clamp in the wrapped normal
cache, plus the earlier session milestones.

The run includes:

- native and WASI unit suites (including the new half-integer gamma CDF
  series-comparison test and the wrapped distribution inverse tests);
- native and WASI distcheck with the continuous/tail/copula gates, the
  scalar and vector binned chi-square gates, and the discrete CDF gates;
- distcheck-libc, statcheck, profilecheck (long/stress/tail), the PractRand
  self-test, the six crosscheck targets, and the chained WASI report.

No library code changed in this milestone.

## Validation

- `zig build validate-all --summary all`: 124/124 steps, 1981/1981 tests.

## Next Bar

Keep the no-known-gaps comparison and the long-run evidence current. The
slowest Alea-only rows are now the wrapped skew-normal quantile (about
0.85M/s) and the skew-normal quantile (about 2.8M/s).
