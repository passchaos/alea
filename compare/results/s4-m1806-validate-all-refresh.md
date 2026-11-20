# S4-M1806 Validate-All Refresh After the Quantile Optimization Wave

Date: 2026-11-20

`zig build validate-all --summary all` passes 124/124 steps and 1979/1979
tests, including native `alea-tests` 976/976 and WASI Node tests 976/976.

The run covers the full S4-M1783..M1805 wave: the Halley steps and their
dominance guard across the skew-normal, wrapped skew-normal, beta, gamma,
von Mises, wrapped normal, ex-Gaussian, and inverse-Gaussian quantiles; the
half-integer beta recurrences; the Owen T Gauss-Legendre band extension, far
tail, and fixed-shape geometry tables; the Marcum and von Mises term-bound
tightening; the direct-form ex-Gaussian and Rice densities; the wrapped
skew-normal image-range bound; and the vector von Mises squeeze gating.

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

Keep the no-known-gaps comparison and long-run evidence current; the
remaining Alea-only slow rows are the wrapped skew-normal quantile (about
0.58M), skew-normal quantile (about 2.6M), and the extreme-shape
`beta(0.1,0.1)` / `gamma(0.05,1)` / `hoyt(q=0.01)` CDF-resolution limits
noted in S4-M1797.
