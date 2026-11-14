# S4-M1554 Noncentral-t Large-dof Quadrature Fix

Date: 2026-11-15

## Gap

The S4-M1548 noncentral-t CDF evaluates the exact χ² mixture
`E_V[Φ(t√(V/ν) − μ)]` with adaptive Simpson in `s = √(V/ν)` for the
quadrants outside the series. For large `ν` the Gamma density is a narrow
spike of width `1/√(2ν)` in `s`; the coarse Simpson nodes can all land in its
zero tails, so the recursion accepts a zero estimate and returns 0. The
extreme-parameter probe found `noncentralTCdf(-1, 1e6, 1) = 6.31e-39` instead
of the normal limit `Φ(-2) = 0.0227501`, and the same failure affected the
`μ > 10, t > 0` and `μ < 0` integral quadrants.

## Change

- For `dof >= 1` the integral now uses the standardized chi scale
  `u = α·e^{z/√α}` (`α = ν/2`), where the Gamma bulk is `O(1)` in `z`
  (the `expm1` form keeps the exponent accurate). The `Φ` factor becomes a
  smooth or step-like function of `z`, which the adaptive recursion can
  refine because the density itself is no longer a missed spike.
- `dof < 1` keeps the `r = s^ν` substitution, which removes the `s^{ν−1}`
  endpoint singularity and avoids the `40/√α` range stretch.
- The adaptive Simpson recursion carries a hard 100k-evaluation budget and a
  depth cap of 24, so a near-step `Φ` transition (large `ν` with the
  transition inside the bulk) degrades gracefully instead of exhausting
  `2^depth` subdivisions.

## Validation

- The extreme-parameter probe now returns `noncentralTCdf(-1, 1e6, 1) =
  0.022750103` (normal limit `0.022750132`), `noncentralTCdf(1, 1e6, 1) =
  0.49999991` (limit `0.5`), and keeps the previously verified
  `(1e300, 1e300, 1e300) = 0.5`, `(1e-300, 1e6, 1) = 0.15865526`, and
  `(1e6, 1e-6, 1) = 0.65866207` values.
- The 19 reference values from S4-M1548 still pass at 1e-6, including the
  integral quadrants `(20, 10, 20)`, `(100, 10, 100)`, `(100, 1, 100)`,
  `(-10, 3, 4)`, and the `dof < 1` cases.
- New regression checks pin `noncentralTCdf(-1, 1e6, 1) = Φ(-2)`,
  `noncentralTCdf(1, 1e6, 1) = Φ(0)`, and
  `noncentralTCdf(0.5, 1e5, 1) = Φ(-0.5)` within the `O(1/ν)` normal-limit
  error.
- `zig build test distcheck --summary all` passes 956/956 tests (native
  `alea-tests` 935/935), including the noncentral-t quantile round-trip
  gates.
- The far lower tail below about `1e-15` remains at the absolute-resolution
  floor (`cdf(-1912, 10, 1)` is below the quadrature's absolute accuracy in
  both the Zig and independent reference implementations); this is the
  documented absolute-accuracy limit, not a regression.

The aggregate `validate-all` refresh is tracked as the following milestone.
