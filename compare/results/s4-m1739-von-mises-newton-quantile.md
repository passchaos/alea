# S4-M1739 Von Mises Safeguarded-Newton Quantile

Date: 2026-11-16

## Change

`vonMisesQuantile` used 64 bisection iterations on the relative CDF, which for
`kappa <= 1e4` sums up to roughly `kappa + 10*sqrt(kappa) + 40` Fourier-Bessel
terms. Replaced it with the same safeguarded Newton pattern used by S4-M1737:

- initial guess: the concentrated normal limit `probit(p)/sqrt(kappa)` for
  `kappa >= 1`, otherwise the uniform quantile `2πp - π`;
- density: `exp(kappa*cos(d) - log(2π) - logBesselI0(kappa))`;
- bracket `[-π, π]`, midpoint fallback when Newton leaves the bracket or the
  density is non-positive, stop on `F(d) == p` or when the bracket is below
  `1e-12` (f64) / `1e-5` (f32).

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216
"von mises"`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea von mises quantile` | 0.063 M quantiles/s | 0.710 M quantiles/s | 11.3x |

The quantile checksum is unchanged (`1966.365`) for the 1000-point p grid; the
sample rows are unchanged within noise.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 985/985
  tests (native `alea-tests` 962/962).
- The existing test covers `kappa` 0.1/1/5/20/1e4/1e5 and `p` from `1e-6` to
  `1-1e-6` at `1e-9` round-trip tolerance.
- Follow-up: S4-M1740 refreshes `validate-all`.
