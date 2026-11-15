# S4-M1611 Tiny-Tail CDF Cancellation Audit

Date: 2026-11-15

## Finding

A `p = 1e-12`/`1e-15` round-trip probe showed a shared `~2.2e-5` (at 1e-12) and
`~8e-4` (at 1e-15) relative error for the Cauchy, Student-t, Rice,
inverse-gamma, and GEV lower tails. The S4-M1574 audit had attributed this to
an f64 representation floor, but the probe showed the errors were formula
cancellations:

- `cauchyCdf` used `0.5 + atan(z)/π`, cancelling both `~0.5` terms;
- `studentTCdfSmallInteger` computed `1 − (1 − 0.5·ib)` for `t < 0` and the
  `ν = 1`/`ν = 2` seeds `1 − 2θ/π` / `1 − sin θ`;
- `betaQuantile` stopped when the absolute bracket was `64·eps`, a large
  relative error for tiny quantiles;
- `inverseGammaQuantile` formed `gammaQuantile(1 − p)`, losing the tiny tail
  in `1 − p`;
- `riceCdf` used `1 − Q1`, cancelling the tiny lower tail;
- `generalizedExtremeValueQuantile` used `−log1p(p − 1)` for all `p`, which
  loses the lower tail because `p − 1` rounds to `−1`;
- `wrappedCauchyCdf` used `0.5 + atan(u)/π` near the cut.

## Fixes

- Cauchy CDF/quantile: `atan(1/|z|)` tail form and `1/tan(πp)` quantile.
- Small-integer Student-t: `ib = 2·atan(√ν/|t|)/π` (odd) and
  `ib = x/(1 + sin θ)` (even), returning `0.5·ib` directly for `t < 0`.
- `betaQuantile`: relative bisection tolerance
  `64·eps·max(hi, floatMin)`.
- `gammaUpperQuantileImpl`: direct bisection on `Q(shape, y) = q`;
  `inverseGammaQuantile`/`scaledInverseChiSquaredQuantile` use it.
- `marcumP1`: lower-incomplete-gamma Marcum series; `riceCdf` uses it.
- GEV quantile: `−log(p)` for `p < 0.5`, `−log1p(p − 1)` above.
- Wrapped Cauchy relative CDF: `atan(1/|u|)` tail form.

## Results (`cdf(quantile(p))` relative error)

| Family | p=1e-12 before | after | p=1e-15 before | after |
| --- | --- | --- | --- | --- |
| Cauchy | `-2.2e-5` | `-2.0e-16` | `-8.0e-4` | `-2.0e-16` |
| Student-t(3) | `-2.2e-5` | `-4.0e-9` | `-8.0e-4` | `-5.3e-7` |
| Student-t(3.5) | `2.6e-7` | `-9.1e-15` | `2.8e-5` | `-5.7e-15` |
| Rice | `-2.2e-5` | `-2.4e-15` | `-8.0e-4` | `-5.5e-15` |
| InverseGamma | `-2.2e-5` | `6.9e-15` | `-8.0e-4` | `7.3e-15` |
| GEV | `-2.2e-5` | `1.9e-14` | `-8.0e-4` | `5.9e-15` |
| Beta quantile | `2.6e-7` | `2.8e-15` | `-3.9e-15` | `-3.9e-15` |
| FisherF | — | `2.4e-15` | — | `6.7e-15` |
| Gamma / chi-squared | — | `~2e-15` | — | `~2e-15` |
| PERT / log-logistic / ExGaussian / skew-normal | — | `~1e-14..1e-16` | — | `~1e-14..1e-16` |

## Remaining Limits

- Pareto/GPD near the location/scale: the quantile is `μ + O(p)` and f64
  cannot represent the offset with better than `eps/p` relative precision
  (`~2e-4` at `p = 1e-12`), independent of the formula.
- Wrapped Cauchy near the `±π` cut: the quantile output is an angle near
  `−π`, and f64 represents the offset `δ = x + π` only to `eps·π/δ`
  relative (`~2.4e-5` at `p = 1e-12`). A local Taylor tail series was tried
  and rejected: it is more accurate than the representation CDF for
  `δ ~ 1e-6..1e-9`, but the quantile's angle representation dominates at the
  smallest `p`, so the extra code did not improve the round-trip there.
- von Mises: the Fourier–Bessel series has a `~1e-15` absolute cancellation
  floor (`3e-5` at `p = 1e-12` for `κ = 5`, `8e-3` at `p = 1e-15`), as
  documented in S4-M1596.

## Validation

- The probe test was removed after the fixes; the permanent tests still pin
  the S4-M1574 reference values and the new tail behavior is covered by the
  round-trip tolerances in `distcheck`.
- `zig build test distcheck --summary all` passes 971/971 tests (native
  950/950).
- The `ScaledInverseChiSquared` tiny-p test now targets `p` itself instead of
  the old `1 − (1 − p)` complement.
- CDF/quantile-only change: no sampling stream, public API, or benchmark
  changed.
