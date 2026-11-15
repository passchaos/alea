# S4-M1688 Windowed Binomial Inversion Fill

Date: 2026-11-16

## Change

The scalar binomial inversion fill (non-dyadic `p`, `trials > 64`,
`mean < 16`) walked the pmf from zero for every sample. It now builds a
windowed inverse-CDF table once per fill: the window covers
`mean +/- 10 sigma`, the lower tail uses the exact `binomialCdf(lo-1)`, and a
uniform outside the window falls back to `binomialFrom`. The binary search
returns the same inverse-CDF index as the inversion walk for the same
uniform, so the per-element stream is unchanged (identical checksum).

The HIN region (`mean >= 16`) keeps the stream-preserving one-setup HIN fill;
the dyadic probabilities keep their packed fast paths.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea fillBinomial mean-12` (1000, 0.012) | 49.6 M samples/s | 96.5 M samples/s | +95% |
| `... mean-12 scalar direct` | 48.3 M samples/s | 90.8 M samples/s | +88% |
| `alea fillBinomial large` (10000, 0.01, HIN) | 33.1 M samples/s | 33-35 M samples/s | unchanged |
| `alea fillBinomial` (40, 0.25, dyadic) | 721.8 M samples/s | 747.1 M samples/s | unchanged/noise |
| `alea fillBinomial scalar direct` (40, 0.25) | 988.8 M samples/s | 989.4 M samples/s | unchanged |

The mean-12 checksum is unchanged (`788021`), confirming the stream-preserving
inversion replacement.

## Distribution Audit

Scratch fill audit (400k samples per case, exact `Binomial.cdf`):

| Case | Mean | Exact mean | max abs CDF error |
| --- | --- | --- | --- |
| (1000, 0.012) | 11.9960 | 12.0000 | 0.00102 |
| (100, 0.1) | 9.9963 | 10.0000 | 0.00112 |
| (200, 0.05) | 9.9964 | 10.0000 | 0.00112 |
| (500, 0.02) | 9.9963 | 10.0000 | 0.00113 |

`tools/distcheck.zig` now gates `fillBinomial(1000, 0.012)` CDF at `8`, `12`,
and `16` over 800k samples.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native 950/950), including the cached-binomial and HIN fill
  stream tests.
- `zig build distcheck --summary all`: 5/5 steps and 2/2 tests.

## Changed Files

- `src/distributions.zig`: `binomialFillWindowFrom` and the fill dispatch.
- `tools/distcheck.zig`: `fillBinomial(1000, 0.012)` CDF gates.
- `compare/results/reproducibility-matrix.md`: records the stream-preserving
  speedup.
