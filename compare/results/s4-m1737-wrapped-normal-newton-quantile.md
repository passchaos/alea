# S4-M1737 Wrapped Normal Safeguarded-Newton Quantile

Date: 2026-11-16

## Change

`WrappedNormal.quantile` used 70 (f64) / 40 (f32) bisection iterations, each
evaluating the `2π` image sum (up to 25 normal-CDF pairs). Replaced it with a
safeguarded Newton iteration on the same CDF:

- initial guess: the normal quantile `mu + sigma*probit(p)` wrapped for
  `sigma <= 2`, otherwise the uniform quantile `-π + 2πp`;
- each iteration evaluates `F(x)` and the wrapped density
  `f(x) = Σ_k φ((x - mu + 2πk)/σ) / σ`;
- a bracket `[lo, hi]` keeps the iteration in `(-π, π]`, falls back to the
  midpoint when Newton leaves the bracket or the density is non-positive, and
  stops on `F(x) == p` or when the bracket is below `1e-12` (f64) / `1e-5`
  (f32).

The image count is shared with the CDF through `wrappedNormalImageCount`, and
the density uses the existing `normPdf`.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216
"wrapped normal"`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea wrapped normal quantile` | 0.068 M quantiles/s | 0.778 M quantiles/s | 11.4x |

The quantile checksum is unchanged (`5876.009`) for the 1000-point p grid,
confirming the same outputs; the sample rows are unchanged within noise.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 985/985
  tests (native `alea-tests` 962/962).
- The existing round-trip test covers `sigma` 0.2/0.5/1/3/9.9 and `p` from
  `1e-4` to `1-1e-4` at `1e-9` tolerance.
- Follow-up: S4-M1738 refreshes `validate-all`.
