# S4-M1576 Weibull and Rayleigh Tiny-Tail Forms

Date: 2026-11-15

## Gap

The S4-M1574 `p = 1e-12` tail audit also flagged `Weibull` and `Rayleigh`
with about `-2.2e-5` relative round-trip error:

- `weibullQuantile` and `rayleighQuantile` computed `log(1 − p)`; for
  `p = 1e-12` the argument `1 − p` carries a one-ulp absolute error, so the
  logarithm's relative error is about `1e-4`.
- `weibullCdf` computed `1 − exp(−(x/scale)^shape)`, which cancels for tiny
  `x`.

## Change

- `weibullCdf` uses `−expm1(−(x/scale)^shape)`.
- `weibullQuantile` and `rayleighQuantile` use `log1p(−p)`.
- `paretoCdf` was also probed with the `−expm1(shape·log1p(−(x−scale)/x))`
  form but reverted: the `x − scale` subtraction loses more precision than
  the ratio-first `1 − (scale/x)^shape` for `x` just above `scale`, so the
  existing form stays.
- `docs/core-guide.md` records the Weibull/Rayleigh tail forms.

## Validation

- The `p = 1e-12` audit no longer flags Weibull or Rayleigh; the new
  relative checks pin `cdf(quantile(1e-12))` within `1e-10` for both and
  `weibullCdf(1e-12)` within `1e-10`.
- `zig build test distcheck --summary all` passes 960/960 tests (native
  `alea-tests` 939/939).
- No sampling stream changes: the Weibull/Rayleigh samplers use their own
  `-log(u)` transforms, not the CDF/quantile helpers.

The remaining `p = 1e-12` floors documented in S4-M1574 are unchanged
(`StudentT`/`Cauchy`/`Rice`/`GPD`/`SICS`/`InverseGamma`/`Pareto` at about
`-2.2e-5` relative from the f64 CDF representation, `SkewNormal` below
`~1e-9`, and the truncated-normal edge representation).
