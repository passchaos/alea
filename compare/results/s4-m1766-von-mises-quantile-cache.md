# S4-M1766 Von Mises Quantile Bessel-Ratio Cache

Date: 2026-11-20

## Gap

The von Mises quantile ran at 0.967M quantiles/s. Each safeguarded-Newton
iteration recomputed two parameter-only quantities:

- the backward Bessel ratio recurrence that normalizes the Fourier–Bessel CDF
  (about 68 divisions for `kappa = 5`), and
- the density normalization `log(2π) + log I₀(kappa)`,

and the CDF itself evaluated a `@sin` per series term (64 terms at
`kappa = 5`).

## Change

`src/distributions.zig` now:

- adds `VonMisesCdfCache`, built once per quantile call for f64
  `0 < kappa <= 1e4` with at most 128 series terms. It records the backward
  Bessel ratios (handling the mid-loop rescale), normalizes them once, and
  precomputes the density log-normalization and the antipode tail prefactor;
- evaluates the cached CDF with the same downward term order but advances
  `sin(k·d)`/`cos(k·d)` through the angle-addition recurrence, resyncing with
  `@sin`/`@cos` every 16 steps so the drift stays near the f64 noise floor;
- keeps the public `vonMisesCdf` and `vonMisesRelativeCdf` on the direct
  `@sin` path, and keeps f32, `kappa > 1e4`, and wide-series parameters on the
  existing fallback.

A new permanent test round-trips the quantile through the public CDF for
`kappa ∈ {0.5, 1, 2, 20, 100, 200}` (the last exercises the cache fallback) and
`p ∈ {0.01, 0.1, 0.5, 0.9, 0.99}` at `1e-10`.

## Measurements

Same host, `ReleaseFast -Dcpu=native`,
`bench -- 17179869184 "von mises"` (4.19M evaluations per row):

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea von mises quantile` | 0.967M quantiles/s | 1.568M quantiles/s | 1.62x |
| `alea von mises cdf` | 4.393M cdf/s | 4.393M cdf/s | unchanged (public path) |

The quantile checksum is unchanged (`2096987.067`), confirming the same
outputs. The harness also gained permanent `alea von mises cdf`,
`alea fisher-f cdf`, and `alea hoyt cdf` diagnostic rows from this and the
previous milestone.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests (including the
  new cached/fallback round-trip test).
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- No reproducibility-matrix mapping change is needed because the quantile
  checksum is identical.

## Next Bar

Refresh validate-all/long-run evidence and continue with the remaining slow
rows (wrapped skew-normal quantile 0.272M, skew-normal quantile 1.031M, and the
vector-directional samplers).
