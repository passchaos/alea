# S4-M1692 Zipf CDF Fill

Date: 2026-11-16

## Change

The scalar `Zipf.fill`/`fillFrom` ran the rejection-inversion sampler per
element (about 68M samples/s at `n = 10, s = 1.5`). For finite integer
supports up to 1024 it now builds the cumulative pmf once per call and draws
each sample with one uniform plus a binary search. Larger, infinite, or
non-integer supports keep the rejection-inversion stream.

This is a versioned scalar bulk-fill stream; `Zipf.sample`/`sampleFrom` keep
the rejection-inversion stream, and the vector Zipf fill still uses the
per-lane sampler. The iterator test now documents the bulk-fill divergence
instead of asserting fill == repeated sample for Zipf.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216
"Zipf.fillFrom"`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea Zipf.fillFrom direct` (10, 1.5) | 68.5 M samples/s | 197.9 M samples/s | 2.9x |
| `alea candidate Zipf.fillFrom cdf direct` (probe) | - | 198.6 M samples/s | - |

The checksum changes (`330159` -> `330202`) because the fill stream is
versioned.

## Distribution Audit

Scratch fill audit (400k samples per case, exact `Zipf.cdf`):

| Case | Mean | max abs CDF error |
| --- | --- | --- |
| (10, 1.5) | 2.5152 | 0.00049 |
| (1024, 1.5) | 24.4285 | 0.00039 |
| (1024, 1.0) | 136.2533 | 0.00072 |
| (2000, 1.5, fallback) | 34.0726 | 0.00076 |
| (inf, 2.0, fallback) | 8.6661 | 0.00026 |

`tools/distcheck.zig` now gates `fillZipf(10, 1.5)` CDF at `2`, `4`, and `8`
over 800k samples.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native 950/950), including the updated iterator test.
- `zig build distcheck --summary all`: 5/5 steps and 2/2 tests with the new
  gates.

## Changed Files

- `src/distributions.zig`: `Zipf.fillCdfFrom` and the fill dispatch; iterator
  test update.
- `bench/throughput.zig`: the CDF probe row.
- `tools/distcheck.zig`: `fillZipf(10, 1.5)` CDF gates.
- `compare/results/reproducibility-matrix.md`: records the versioned bulk
  fill stream.
