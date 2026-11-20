# S4-M1846 Skip the Gamma Quantile Bracket Verification

Date: 2026-11-20

## Gap

`gammaQuantileImpl` starts from `hi = scale·max(1, shape)` and verifies the
upper bracket with a full CDF evaluation (`while gammaCdf(hi) < p`) before
the Halley loop. That check costs at least one CDF evaluation on every
call — and a second one when the initial `hi` is below the target — even
though `mean + 40 standard deviations` is a guaranteed bound for the shape
range where the Wilson-Hilferty start is used.

The upper tail at that point is `Q(a, a + 40·sqrt(a))`, which measures
8.4e-12 at the `a = 0.3` boundary and falls to 1e-18 at `a = 1` and 1e-26
at `a = 2.5`. The main path only handles `p <= 1 − 1e-7`, so the bracket
cannot fail.

## Change

For `shape >= 0.3` the upper bracket is set directly to
`scale·(shape + 40·sqrt(shape))` and the verification loop is skipped;
smaller shapes keep the expansion loop, and the `1 − p < 1e-7` tail branch
still expands from that bracket.

## Measurements

- Direct `gammaQuantile(p, 2.5, 2)` sweep: 158.1 ns → 133.9 ns per call
  (about −15%) with an identical checksum.
- Same-host A/B with two separately built `bench/throughput.zig` binaries
  (`ReleaseFast -Dcpu=native`, `-- 16777216`), four alternating pairs:
  `gamma quantile` 6.116, 5.677, 6.020, 6.202 M/s before and 8.015, 7.585,
  6.818, 7.599 M/s after (median 6.068M to 7.592M, about +25%);
  `chi-squared quantile` (which routes through the same function) 4.584,
  3.291, 4.331, 4.097 M/s before and 4.474, 5.253, 5.209, 5.228 M/s after
  (median 4.214M to 5.219M, about +24%).

## Accuracy

A round-trip audit over `shape ∈ {0.05, 0.1, 0.3, 0.5, 1, 2, 2.5, 5, 20,
100, 1000, 9999}` and `p` from 1e-12 to `1 − 1e-9` gives a worst relative
error of 1.98e-11 (at `shape = 9999`, the Wilson-Hilferty fallback).

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The gamma quantile is now about 7.6M quantiles/s and the chi-squared
quantile about 5.2M/s. Keep the no-known-gaps and long-run evidence current;
the large-hypergeometric codegen gap (0.86-0.87x) remains the only
sub-parity comparable workload.
