# S4-M1732 Vector Binomial Non-Dyadic Gate Low-Count Merge

Date: 2026-11-16

## Problem

The S4-M1731 wrapped-normal gates shift the shared distcheck RNG stream. With
the shifted stream, `checkVectorBinomialPmfBins(40, 0.4, ...)` failed with a
chi-square of 601.7 against the 29.45 bound. The per-bin diagnostics showed the
sampler matched every main bin:

- expected `0.01554` vs observed `38816` for 5..9,
- expected `0.30185` vs observed `754277` for 10..14,
- expected `0.55281` vs observed `1382373` for 15..19,
- expected `0.12641` vs observed `316119` for 20..24,

but the extreme tail bucket (35..40) had expected count `0.00166` and observed
`1`. That single sample contributed about `600` to the statistic, so the
failure was a gate-design issue, not a sampler defect: chi-square buckets with
expected counts far below one are not valid.

## Fix

`checkVectorBinomialPmfBins` now merges adjacent pmf buckets until every
expected count is at least 5 (Cochran's rule), including a final merge when the
last bucket is still below 5, and computes the statistic and degrees of freedom
over the merged buckets. The main bins keep their sensitivity to real
distribution errors; rare tail samples no longer dominate the statistic.

## Validation

- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)` with the shifted stream.
- `zig build test distcheck statcheck --summary all`: 39/39 steps and 984/984
  tests (native `alea-tests` 961/961).
- Tooling-only: no library stream or public API changed.
