# S4-M1793 Halley Step for the von Mises Quantile

Date: 2026-11-20

## Gap

The von Mises quantile ran safeguarded Newton on its cached Fourier–Bessel
CDF. The relative density derivative is one line, `−κ·sin(d)·f'`, and the
loop already evaluates the density each iteration. The row measured
2.83-2.89M quantiles/s.

## Change

The loop takes a Halley step (`2 f f' / (2 f'^2 − f f'')`) when the CDF is
representable, the density is positive and finite, and the denominator is
positive and finite; a candidate outside `[lo, hi]` falls back to the existing
bisection, and Newton remains the base step. This mirrors the gated form used
by the gamma quantile.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `von mises quantile` | 2.834, 2.874, 2.894 | 3.520, 3.541, 3.569 |

About +23% with an unchanged checksum.

## Correctness audit

Every Halley-upgraded quantile was round-tripped against its own CDF over 2000
probabilities: beta `(2,3)`, `(2.5,0.5)`, `(0.5,2.5)`, `(5,5)` worst
`1.33e-13`; gamma `(2.5,1)` and `(5,2)` worst `1.10e-14`; chi-squared `(5)`
worst `7.11e-15`; von Mises `κ = 5` and `κ = 20` worst `1.65e-12`;
skew-normal `α = 2` worst `5.78e-13`; wrapped skew-normal worst `7.98e-11`
(inside its 1e-9 contract). The inverse-Gaussian quantile was also tried and
rejected: its Halley step produced a spurious root at `p = 0.0795`
(`x = 0.00797` with `CDF = 1.3e-55` instead of `x = 0.33136`), so that
experiment was reverted before landing.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps comparison current; the wrapped skew-normal quantile
remains the slowest model row.
