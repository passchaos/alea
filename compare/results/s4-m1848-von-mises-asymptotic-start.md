# S4-M1848 Asymptotic Start for the von Mises Ratio Recurrence

Date: 2026-11-20

## Gap

`VonMisesCdfCache.init` started its backward Bessel-ratio recurrence from
`rho = 0` and needed a wide margin (`ceil(kappa + 6·sqrt(kappa) + 12)`,
31 steps at `kappa = 5`) to converge before the truncation. The recurrence
is latency-bound at about 3.5 ns per step, so the setup was roughly 109 ns
of the 256 ns von Mises quantile.

For `kappa <= 50` the ratio has a good asymptotic form,
`I_k/I_{k-1} ~ h·(1 − h²·k/(k+1))` with `h = kappa/(2k)`, and the residual
decays by about `h²` per backward step: seven steps above the truncation
reach the f64 noise floor. For larger `kappa` `h` approaches 1 and the
expansion is useless, so those shapes keep the zero-start margin.

## Change

For `kappa <= 50` the recurrence starts at the asymptotic ratio with a
seven-step margin; otherwise the previous zero-start margin
(`1.5·sqrt(kappa) + 8` steps, which is slightly tighter than the old
formula but measured equivalent) is used. The `k_sum` truncation is
unchanged.

## Accuracy

The coefficient table differs from the old start by at most 1.54e-13
relative across `kappa ∈ {0.5, 1, 2, 5, 10, 20, 50, 100}`; the round-trip
audit over `kappa ∈ {0.5 … 1e4}` and nine probabilities gives a worst error
of 1.6151524562246777e-12 — bit-identical to the pre-change value.

## Measurements

- Direct `vonMisesQuantile(p, 0.5, 5)` sweep: 255.6 ns → 239.8 ns per call
  (about −6%).
- Same-host A/B with two separately built `bench/throughput.zig` binaries
  (`ReleaseFast -Dcpu=native`, `-- 16777216`), four alternating pairs:
  `von mises quantile` 3.968, 3.861, 3.988, 3.986 M/s before and 4.221,
  4.346, 4.345, 4.356 M/s after (median 3.987M to 4.345M, about +9%).

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The von Mises quantile is now about 4.35M quantiles/s. Keep the
no-known-gaps and long-run evidence current; the large-hypergeometric
codegen gap (0.86-0.87x) remains the only sub-parity comparable workload.
