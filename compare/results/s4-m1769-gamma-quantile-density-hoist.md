# S4-M1769 Gamma Quantile Density Normalization Hoist

Date: 2026-11-20

## Gap

The generic gamma quantile recomputed the density log normalization
`lgamma(shape) + shape·log(scale)` on every safeguarded-Newton iteration. The
same hoist was tested for the beta quantile and rejected.

## Change

`src/distributions.zig` now precomputes the gamma log normalization once before
the Newton loop and passes it to `gammaPdfWithLogNorm`. The arithmetic
expression is unchanged, so every output is bit-identical. The beta quantile
keeps its per-call `lgamma` because the hoisted variant regressed the generic
`Beta(2.5, 0.5)` quantile from 1.15M to 0.88M quantiles/s (the compiler already
hoists the pure `lgamma` calls and inlines the density better without the extra
live value).

## Measurements

Same host, `ReleaseFast -Dcpu=native`,
`bench -- 17179869184 "<filter>"` (4.19M evaluations per row):

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea chi-squared quantile` | 2.693M quantiles/s | 3.226M quantiles/s | 1.20x |
| `alea gamma quantile` | 4.996M | 5.093M | 1.02x |
| `alea beta (2.5,0.5) quantile` | 1.150M | 1.152M | unchanged (rejected variant reverted) |

Checksums are unchanged: chi-squared `20967375.727`, gamma `25159904.902`,
beta `3495287.622`.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- No reproducibility-matrix mapping change is needed because the outputs are
  bit-identical.

## Next Bar

Run the 1e9 long-run refresh and continue with the remaining
Owen-T-limited quantile rows.
