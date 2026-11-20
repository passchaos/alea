# S4-M1811 Relative-Width Log Refinement for Tiny Gamma Quantiles

Date: 2026-11-20

## Gap

`gammaQuantile` refined its lower tail in log space only when the bracket's
lower end collapsed to exactly zero (`lo == 0`). For tiny-shape quantiles the
bracket instead ends with an absolute width near the 1e-12 tolerance while
`hi` itself is around `1e-20`, so the quantile was left with a wide *relative*
bracket and a large CDF error. The audit showed
`gammaQuantile(0.111, 0.05, 1)` returning a point whose CDF was `7.63e-3` off
(the pre-Halley code had the same defect).

## Change

The log-space refinement now triggers when `p > 0` and either `lo == 0` or
`hi - lo > hi·1e-6` (the bracket is still wide relative to a tiny `hi`). The
refinement itself is unchanged. The same trigger was tried on the beta
quantile and reverted: it changed no measured case (the remaining beta
extreme-tail failures are representability limits).

## Accuracy

- `gammaQuantile` round-trip over 2000 probabilities for
  `shape ∈ {0.02, 0.05, 0.1, 0.5}`: worst `|CDF(q) − p|` drops from `9.24e-3`
  to `2.22e-15`.
- The extreme-shape audit's `gamma(0.05,1)` row moves from
  `7.63e-3 [FAIL]` to `5.55e-16 [ok]`; every other audited row is unchanged.

## Performance

The refinement only runs in the degenerate cases, so the benched
`gamma quantile` row is unchanged within noise (5.46-6.25M versus
5.71-6.24M quantiles/s) with an unchanged checksum.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps and long-run evidence current; the remaining
extreme-shape limits are the `beta(0.1,0.1)` upper tail (the true quantile is
within one ulp of 1.0) and the pre-existing `hoyt(q=0.01)` series convergence
issue.
