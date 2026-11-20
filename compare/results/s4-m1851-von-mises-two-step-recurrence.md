# S4-M1851 Two-Step von Mises Ratio Recurrence

Date: 2026-11-20

## Gap

The von Mises ratio table walks `rho_{k-1} = 1/(2k/kappa + rho_k)` one step
at a time, and each step's reciprocal sits on the dependency chain
(about 3.5 ns per step). After S4-M1848 the table is 27 steps at
`kappa = 5`, still roughly 95 ns of the 240 ns quantile.

## Change

The loop now advances two steps per iteration with the composed update

`t = 2k/kappa + rho_k`, `rho_{k-2} = t / ((2(k-1)/kappa)·t + 1)`,

so one division remains on the dependency chain per two steps. The
intermediate reciprocal `1/t` only feeds the ratio product and overlaps
with the chain; the odd final step is handled separately, and the overflow
rescale still covers both indices.

## Measurements

- Direct `vonMisesQuantile(p, 0.5, 5)` sweep: 239.8 ns → 217.5 ns per call
  (about −9%) with an identical checksum.
- Same-host A/B with two separately built `bench/throughput.zig` binaries
  (`ReleaseFast -Dcpu=native`, `-- 16777216`), four alternating pairs:
  `von mises quantile` 3.580, 3.746, 3.756, 3.752 M/s before and 4.392,
  4.139, 3.808, 4.294 M/s after (median 3.749M to 4.217M, about +12.5%;
  all four pairs).

## Accuracy

The coefficient table differs from the one-step table by at most 8.3e-13
relative across `kappa ∈ {0.5 … 300}`; the round-trip audit over
`kappa ∈ {0.5 … 1e4}` and nine probabilities gives 1.61493e-12 worst,
versus 1.61515e-12 before.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The von Mises quantile is now about 4.2-4.4M quantiles/s. Keep the
no-known-gaps and long-run evidence current; the large-hypergeometric
codegen gap (0.86-0.87x) remains the only sub-parity comparable workload.
