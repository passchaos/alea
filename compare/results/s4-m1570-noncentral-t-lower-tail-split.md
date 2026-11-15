# S4-M1570 Noncentral-t Extreme Lower-Tail Split

Date: 2026-11-15

## Gap

After S4-M1568 fixed the upper tail, a probe of the extreme lower tail found
that `noncentralTCdf` for `dof < 1` could not resolve quantiles below about
`p = 1e-10`: at `(0.5, 2)` the `p = 1e-12` quantile hit `−floatMax` and the
round-trip CDF returned `4.0e-11` instead of `1e-12`. The scaled lower-tail
integral runs over `r ∈ [0, upper]` with a finite density at `r = 0`; for very
negative `t` the `Φ(t·s − μ)` transition sits at `r* = ((μ+40)/|t|)^ν`, far
below the quadrature's resolution, so the endpoint step left a spurious
`~4e-11` integral.

## Change

- For the small-dof scaled lower tail (`t < 0`, `μ > 0`) the integration range
  is truncated at `s = (μ+40)/|t|` (`r = s^ν`), matching the complement-side
  split. Beyond that point `Φ(t·s − μ) < Φ(−40)`, so the dropped contribution
  is below `1e-17`.
- `docs/core-guide.md` records the lower-tail truncation.
- The monotonicity grid now also checks relative round-trips at
  `q ∈ {1e-6, 1e-10}` with `1e-5` relative tolerance (the `dof = 3, μ = −2`
  symmetry path leaves about `1e-6` relative error).

## Validation

- `(0.5, 2)` now returns a finite `p = 1e-12` quantile
  (`-9.476805e19`) with `cdf(quantile(1e-12)) = 1e-12` to `2e-16` relative
  error; `p = 1e-6` and `1e-10` are exact.
- All `dof >= 1` lower tails round-trip to about `1e-15` relative error down
  to `1e-12` (unchanged).
- `zig build test -Dtest-filter=oncentral` passes 60/60, including the new
  relative tail checks and the 19 S4-M1548 reference values.

The aggregate `validate-all` refresh is tracked as the following milestone.
