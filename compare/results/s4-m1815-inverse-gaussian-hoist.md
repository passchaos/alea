# S4-M1815 Hoisted Inverse-Gaussian CDF Constant

Date: 2026-11-20

## Gap

`inverseGaussianCdf` formed its lower-tail term in log space:
`exp(2λ/μ + log Φ(z₂))`. The quantile calls it every iteration, so each
evaluation paid a `normLogCdf` plus an `exp`, and the `2λ/μ` division was
recomputed per call. The inverse-Gaussian quantile measured 3.26-3.48M
quantiles/s and `inverseGaussianCdf` about 15.8 ns.

## Change

- The public CDF uses the direct form `exp(2λ/μ)·Φ(z₂)` whenever
  `2λ/μ < 700` and `z₂ > -10`, skipping the log; the log-space branch remains
  for the deep lower tail and extreme scales.
- `inverseGaussianCdfWithExp` takes the precomputed `exp(2λ/μ)` constant, and
  the quantile loop hoists it once per call.

## Measurements

Same-host A/B (`ReleaseFast -Dcpu=native`, `-- 16777216` for the quantile
row), alternating old/new:

| Row | Before | After |
| --- | --- | --- |
| `inverse-gaussian quantile` | 3.258, 3.361, 3.478M/s | 4.143, 4.258, 4.271M/s |
| `inverseGaussianCdf` (direct probe) | 15.8 ns | 10.0 ns |

About +23% on the quantile row and +37% on the public CDF, with unchanged
checksums.

## Correctness audit

Round-trip over 2000 probabilities for `shape ∈ {0.5, 1, 2, 10, 100}`: worst
`|CDF(q) − p| = 3.77e-15`, identical to the log-space version.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps and long-run evidence current; the wrapped
skew-normal quantile remains the slowest Alea-only row.
