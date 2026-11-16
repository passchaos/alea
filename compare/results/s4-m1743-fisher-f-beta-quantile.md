# S4-M1743 FisherF Beta-Quantile Transformation

Date: 2026-11-16

## Change

`fisherFQuantile` used a 100-iteration bisection on `fisherFCdf`
(0.112M quantiles/s). If `X ~ F(d1, d2)`, then
`Y = d1·X/(d1·X + d2) ~ Beta(d1/2, d2/2)`, so the quantile is
`X = d2·Y/(d1·(1−Y))` with `Y = betaQuantile(p, d1/2, d2/2)`. This removes
the Fisher CDF bisection and reuses the beta quantile.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216
"quantile"`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea fisher-f quantile` | 0.112 M quantiles/s | 0.206 M quantiles/s | 1.8x |

The quantile checksum is unchanged (`4462.138`). Core quantile baselines were
also added for future work: `alea pert quantile` 0.355M/s, `alea beta quantile`
0.575M/s, `alea gamma quantile` 0.298M/s, `alea student-t quantile` 0.194M/s,
and `alea chi-squared quantile` 0.191M/s.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 985/985
  tests (native `alea-tests` 962/962).
- Existing FisherF quantile tests (known values and p = 0.1/0.5/0.9) pass;
  StudentT/PERT/Dirichlet users of `betaQuantile` are unaffected.
- Follow-up: S4-M1744 refreshes `validate-all`.
