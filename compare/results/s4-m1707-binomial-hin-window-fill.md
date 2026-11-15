# S4-M1707 Binomial HIN Window Fill

Date: 2026-11-16

## Change

The S4-M1688 windowed inverse-CDF fill was limited to the inversion region
(`mean < 16`). The window covers `mean +/- 10 sigma` and already falls back
to `binomialFrom` for the tails, so the guard is removed: the HIN region now
also uses the windowed CDF bulk fill whenever the window fits
(`width <= 512`). `sample`/`sampleFrom` keep the HIN stream; the fill is a
versioned bulk stream.

The `(10000, 0.01)` case builds a 201-entry window once per fill; wider
windows (larger variance) keep the stream-preserving one-setup HIN fill.

Tests updated:

- `binomial HIN fill uses the windowed bulk stream` replaces the old
  fill==repeated-sample assertion with fill==fillFrom, sample==sampleFrom,
  and range checks.
- The cached-binomial test marks HIN fills as `fill_matches = false` while
  the per-sample streams still match.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea fillBinomial large` (10000, 0.01) | 33-35 M samples/s | 85.5 M samples/s | 2.5x |
| `alea fillBinomial large scalar direct` | 32-35 M samples/s | 81.1 M samples/s | ~2.4x |
| `alea fillBinomial mean-12` | 96.5 M samples/s | 96.4 M samples/s | unchanged |
| `alea fillBinomial` (40, 0.25, dyadic) | 747.1 M samples/s | 747.6 M samples/s | unchanged |
| `alea fillBinomial scalar direct` (40, 0.25) | 989.4 M samples/s | 1000.9 M samples/s | unchanged/noise |

The large-row checksum changes (`6553977` -> `6558205`) because the HIN fill
stream is versioned; the mean-12 checksum is unchanged.

## Distribution Audit

`tools/distcheck.zig` now gates `fillBinomial(10000, 0.01)` CDF at `90`,
`100`, and `110` over 800k samples. `distcheck -- --long 10000000` passes the
full long gate set (`distlongcheck ok (10000000 samples)`).

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 974/974
  tests (native 951/951).

## Changed Files

- `src/distributions.zig`: removed the inversion-only guard, updated the HIN
  fill stream tests and the cached-binomial fill flag.
- `tools/distcheck.zig`: `fillBinomial(10000, 0.01)` CDF gates.
- `compare/results/reproducibility-matrix.md`: records the versioned HIN fill
  stream.
