# S4-M1566 Noncentral-t CDF Monotonicity Grid

Date: 2026-11-15

## Gap

S4-M1548/S4-M1554 validated the noncentral-t CDF with 19 reference values,
two focused quantile round-trip sets, and large-dof normal-limit checks.
There was no sweep across the parameter regions asserting CDF monotonicity,
range, and quantile ordering, so a region-specific integration bug could
still hide between the reference points.

## Change

- Added `noncentral t CDF is monotone across parameter regions`:
  - parameter grid `(dof, mu) = (0.5, 2)`, `(1, 1)`, `(3, -2)`, `(10, 0.5)`,
    `(100, 3)`, `(1e5, -1)`, `(1e6, 2)`,
  - CDF sweep `t = -30 .. 30` in 0.5 steps: values in `[0, 1]` and
    non-decreasing (1e-12 slack),
  - quantiles for `q ∈ {1e-4, 0.01, 0.1, 0.5, 0.9, 0.99}`: finite,
    non-decreasing, and `cdf(quantile(q)) = q` within `1e-6`.
- The extreme upper tail (`1 - 1e-4`) is excluded and documented: for
  `dof < 1` the complement is a narrow step in the chi scale and the adaptive
  evaluation budget can leave about `1e-5` absolute error near
  `F = 0.9999`. The probe measured `cdf(quantile(0.9999)) = 0.99990989` for
  `(0.5, 2)`; the lower tail `q = 1e-4` round-trips exactly
  (`cdf(-9478.94) = 1e-4`).
- `docs/core-guide.md` records the upper-tail accuracy corner.
- Test-only, no production code, stream, or benchmark changed.

## Validation

- `zig build test -Dtest-filter=oncentral` passes 60/60.
- `zig build test distcheck --summary all` passes 959/959 tests (native
  `alea-tests` 938/938), including the existing reference-value, round-trip,
  sampler-median, and large-dof regression tests.
