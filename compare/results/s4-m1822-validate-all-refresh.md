# S4-M1822 Validate-All Refresh After the Density and Rule Optimizations

Date: 2026-11-20

`zig build validate-all --summary all` passes 124/124 steps and 1979/1979
tests, including native `alea-tests` 976/976 and WASI Node tests 976/976.

The run covers the S4-M1815..M1821 changes: the hoisted inverse-Gaussian CDF
constant, the per-call Owen T table in the public wrapped skew-normal CDF,
the gated 20-point Owen T rule, the Hoyt/Marcum `P(1, y)` exponential reuse,
the direct-form Hoyt and inverse-Gaussian densities, and the single-division
von Mises ratio recurrence, plus the earlier session milestones.

The run includes:

- native and WASI unit suites (including the quantile round-trip and
  extreme-shape tests);
- native and WASI distcheck with the continuous/tail/copula gates, the
  scalar and vector binned chi-square gates, and the discrete CDF gates;
- distcheck-libc, statcheck, profilecheck (long/stress/tail), the PractRand
  self-test, the six crosscheck targets, and the chained WASI report.

No library code changed in this milestone.

## Validation

- `zig build validate-all --summary all`: 124/124 steps, 1979/1979 tests.

## Next Bar

Keep the no-known-gaps comparison and the long-run evidence current. Known
remaining limits: the `beta(0.1,0.1)` upper tail is bounded by f64
representability near 1.0, and `hoyt(q=0.01)` needs a small-q reformulation.
The slowest Alea-only row remains the wrapped skew-normal quantile (about
0.6M/s).
