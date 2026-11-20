# S4-M1830 Multiply by the Cached 2/kappa in the von Mises Ratio Table

Date: 2026-11-20

## Gap

`VonMisesCdfCache.init` builds the Bessel-ratio table with the backward
recurrence `t = 2k/κ + rho; ratio *= t; rho = 1/t`. Every step divided
`2k/κ` directly, so the setup carried two divisions per step — about 35
steps at `κ = 5`. The setup measured 127 ns of the 279 ns von Mises
quantile, nearly half the call.

## Change

`2/κ` is constant, so it is computed once per setup and each step uses
`k * two_over_kappa` — one multiply instead of a division. Only the
reciprocal of `t` remains. A multiply by a precomputed reciprocal is within
one ulp of the direct division, so the table values are unchanged at this
precision.

## Measurements

- Direct `VonMisesCdfCache.init(5)` timing (best of three trials of 2M
  calls): 127.0 / 126.6 ns before, 124.3 / 123.5 / 123.4 ns after.
- `vonMisesQuantile(p, 0.5, 5)` sweep: 279.22 ns before, 269.87 ns after
  (identical best-of-three values across trials).
- Same-host A/B with two separately built `bench/throughput.zig` binaries
  (`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:
  `von mises quantile` 3.743, 3.553, 3.782, 3.163 M/s before and 3.693,
  3.810, 3.821, 3.816 M/s after (median 3.66M to 3.82M, about +4%) with
  identical checksums.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The von Mises quantile setup is now about 123 ns of a 270 ns call; the
serial recurrence is latency-bound at roughly 3.5 ns per step. Keep the
no-known-gaps and long-run evidence current.
