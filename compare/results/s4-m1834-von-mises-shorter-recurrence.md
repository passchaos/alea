# S4-M1834 Four Fewer Steps in the von Mises Ratio-Table Start

Date: 2026-11-20

## Gap

`VonMisesCdfCache.init` started its backward Bessel-ratio recurrence at
`ceil(kappa + 6·sqrt(kappa) + 16)`, which is 35 steps at `kappa = 5` — about
123 ns, or nearly half of the 270 ns von Mises quantile. The recurrence
converges much faster than that bound assumes: the truncation error decays
by roughly `(kappa/(2k))²` per step as the walk moves down.

## Change

The start drops four steps: `ceil(kappa + 6·sqrt(kappa) + 12)`. Comparing
the resulting coefficients against the old start over `kappa ∈ {1, 2, 5,
10, 20, 50, 100}` shows a worst relative error of 3e-14 (at `kappa = 5` and
`10`); six fewer steps would already reach 6.7e-13 at `kappa = 10`, so four
is the safe cut.

## Accuracy

A round-trip audit over `kappa ∈ {0.5, 1, 2, 5, 10, 20, 50, 100, 500, 5000,
1e4}` and nine probabilities from 1e-6 to `1 - 1e-6` gives a worst
`|CDF(quantile(p)) − p|` of 1.615e-12 — bit-identical to the old start's
worst, so the table change does not move the achieved accuracy (the loop's
own convergence dominates).

## Measurements

- Direct `vonMisesQuantile(p, 0.5, 5)` sweep over 2M probabilities (best of
  five trials): 269.99 ns before, 255.64 ns after (about −5.3%) with
  identical checksums.
- Same-host A/B with two separately built `bench/throughput.zig` binaries
  (`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:
  `von mises quantile` 3.219, 3.052, 3.061, 2.963 M/s before and 3.135,
  3.164, 3.146, 3.223 M/s after (median 3.057M to 3.155M, about +3% in a
  noisy window; three of four pairs favor the change).

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The von Mises quantile setup is now about 109 ns of a 256 ns call. Keep the
no-known-gaps and long-run evidence current, and revisit the
large-hypergeometric codegen gap.
