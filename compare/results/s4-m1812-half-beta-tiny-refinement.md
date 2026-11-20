# S4-M1812 Tiny-Quantile Log Refinement for the Half-Integer Beta Path

Date: 2026-11-20

## Gap

The half-integer beta quantile (`betaQuantileRecurrence`, used for
`b = 1/2` or `a = 1/2` with a half-integer partner) had no log-space lower
tail refinement. For `betaQuantile(1e-12, 0.5, 2.5)` the true quantile is
about `3.5e-25`, below the linear bisection resolution, and the loop returned
`x = 1.45e-19` whose CDF was `6.45e-10` — a `6.4e2` relative error.

## Change

After the Newton loop, when `p > 0` and either `lo == 0` or the bracket is
still wide relative to a tiny `hi` (`hi - lo > hi·1e-6`), the path bisects in
log space over `[log(floatMin), log(hi)]` using the same recurrence CDF
(`betaCdfHalfAWithPdf` / `betaCdfHalfBWithPdf`). The generic beta quantile and
the integer-`b` path are unchanged.

## Accuracy

Tiny-probability sweep `p ∈ {1e-12, 1e-8, 1e-4, 0.01}` with
`a, b ∈ {0.1, 0.5, 2.5}`: worst relative round-trip error drops from
`6.44e2` to `6.56e-7` (absolute CDF error `6.45e-10` -> `6.6e-19`).
The 14-row extreme-shape audit is unchanged (the remaining
`beta(0.1,0.1)` failure is the upper-tail representability limit: the true
quantile is within one ulp of 1.0).

## Performance

The refinement only triggers for tiny quantiles. The benched
`beta (2.5,0.5) quantile` row is unchanged within noise (6.85-7.09M versus
6.74-7.47M quantiles/s) with an unchanged checksum, and the integer-shape
`beta quantile` row is untouched.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps and long-run evidence current; the remaining
extreme-shape limits are the `beta(0.1,0.1)` upper tail and the pre-existing
`hoyt(q=0.01)` series convergence issue.
