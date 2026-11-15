# S4-M1568 Noncentral-t Complementary Series Upper Tail

Date: 2026-11-15

## Gap

S4-M1566's monotonicity grid showed that the upper tail of the
`dof < 1`, `mu > 0` noncentral-t CDF was inaccurate: at `(0.5, 2)` the CDF
returned `0.99990989` at `t = 2^26` where the brute-force reference is
`0.999870807` (an absolute error of `3.9e-5`). The direct series computes
`F = Φ(−μ) + Σ w_j A_j`; near `F = 1` the positive sum approaches `Φ(μ)` and
the small complement is lost to cancellation. The `x = t²/(t²+ν)` argument
also rounds to one for huge `t`, so `A₀ = ½·I_x(½, ν/2)` returns exactly
`½` and the `B₀` tail information is lost.

## Change

- `noncentralTCdfSeriesF64` now accumulates a second, all-positive series
  for the upper complement:
  - `B_j = E[n_j(W)]`, `n_j(c) = ∫_c^∞ r^j φ(r) dr`,
  - `B₀ = ½·I_y(ν/2, ½)` with `y = ν/(t²+ν)` (computed directly, so it
    survives `x` rounding to one),
  - `B₁ = E[φ(W)] = c_scale`,
  - `B_j = (j−1)B_{j−2} + c_{j−1}` (same `c_{j−1}` moments as the `A`
    recurrence),
  - the loop returns `1 − sum_b` when `sum_b <= 0.5` and
    `Φ(−μ) + sum_a` otherwise, so whichever side is small keeps its relative
    accuracy.
- The integral path computes the complement `Φ(μ − t·s)` directly for
  `t > 0, μ > 0` and restricts the range to where the complement is
  non-negligible (`s < (μ+40)/t`), keeping the transition inside a small
  panel.
- `docs/core-guide.md` documents the complementary series and removes the
  former `1e-5` upper-tail corner.

## Validation

- `noncentralTCdf(2^26, 0.5, 2)` now returns `0.9998708070591725`, matching
  the brute-force reference exactly; `t = 1e8`, `2e8`, and `1e9` match the
  reference to the last printed digit (`0.9998941651428741`,
  `0.9999251634548404`, `0.9999665320795643`).
- The monotonicity grid now includes `q = 1 − 1e-4` and passes all seven
  `(dof, mu)` sets with `cdf(quantile(q)) = q` within `1e-6`; the
  `(0.5, 2)` quantile moves from the bracket-limited `67108864` to
  `112010169.8`.
- `zig build test -Dtest-filter=oncentral` passes 60/60.
- The 19 S4-M1548 reference values and the large-dof normal-limit checks
  still pass; the body CDF values are unchanged to `1e-6`.

The aggregate `validate-all` refresh is tracked as the following milestone.
