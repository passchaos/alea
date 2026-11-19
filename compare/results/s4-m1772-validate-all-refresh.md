# S4-M1772 Validate-All Refresh After the Owen T Far-Tail Work

Date: 2026-11-20

`zig build validate-all --summary all` passes 124/124 steps and 1979/1979
tests, including native `alea-tests` 976/976 and WASI Node tests 976/976.

The run covers the S4-M1768..M1771 changes:

- the quantile-only wrapped skew-normal image skip (`|z| >= 6.5`);
- the gamma quantile density-normalization hoist;
- the Owen T far-tail closed form, including the extended Owen T accuracy
  comparison against adaptive Simpson for `h` 3-10 and `a` 0.5-6;
- native and WASI distcheck with the continuous/tail/copula gates, the scalar
  and vector binned chi-square gates, the discrete CDF gates, distcheck-libc,
  statcheck, profilecheck (long/stress/tail), the PractRand self-test, the six
  crosscheck targets, and the chained WASI report.

No library code changed in this milestone; it records the aggregate evidence
after the performance work.

## Neutral experiments this turn

- Replacing `Q(1/2, z²/2)` in the skew-normal upper tail with the Mills series
  raised the wrapped CDF by only 13% but broke Newton convergence for the
  quantile (0.342M -> 0.115M quantiles/s) because the Mills series is
  inaccurate for `z < 6`; reverted.
- Loosening the skew-normal quantile bracket tolerance from `1e-12` to `1e-9`
  was neutral (1.016M -> 1.025M quantiles/s, unchanged checksums); reverted to
  keep the documented tolerance.

## Validation

- `zig build validate-all --summary all`: 124/124 steps, 1979/1979 tests.
- `zig build test --summary all`: 995/995 (from S4-M1771).
- The 1e9 long-run evidence remains `s4-m1770-1e9-long-run-refresh.md`.

## Next Bar

Continue with the remaining slow sampling rows (vector-directional
kent/bingham/watson) and broaden the platform evidence.
