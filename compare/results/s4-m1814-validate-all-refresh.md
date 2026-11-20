# S4-M1814 Validate-All Refresh After the Quantile Fixes

Date: 2026-11-20

`zig build validate-all --summary all` passes 124/124 steps and 1979/1979
tests, including native `alea-tests` 976/976 and WASI Node tests 976/976.

The run covers the full S4-M1783..M1813 session: the Halley quantile wave and
its dominance guard, the Owen T geometry tables / band extension / far tail,
the Marcum and von Mises term-bound tightening, the direct-form ex-Gaussian
and Rice densities, the wrapped normal/skew image-range bounds, the Taylor
erfc, the Rice Wilson-Hilferty start, the tiny-quantile log refinements for
gamma and the half-integer beta path, plus the refreshed 1e7 and 1e9 long-run
evidence (S4-M1807/M1813).

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
representability near 1.0, and `hoyt(q=0.01)` needs a small-q reformulation
of its series. The slowest Alea-only row remains the wrapped skew-normal
quantile (about 0.53M/s).
