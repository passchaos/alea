# S4-M1684 Vector Binomial Large-Trial CDF Fill

Date: 2026-11-16

## Change

The S4-M1664 hoisted-CDF fill was limited to `trials <= 128` and used a
branchless scan over every table entry. For larger trials the fill fell back
to the per-lane sampler (about 16-17M lanes/s at 200 trials). Extended the
fill table to `trials <= 1024` and added a per-lane binary search over the
hoisted table for widths above 128; the branchless full-table scan stays for
widths up to 128, where it is faster. `sample`/`sampleFrom` keep their
existing per-vector paths (the <=128 CDF scan or the per-lane sampler), so the
fill stream is a documented bulk policy for `129..1024` trials.

Also fixed a latent underflow bug: the forward pmf recurrence starts at
`(1-p)^trials`, which underflows to zero for extreme `p` (for example
`Binomial(128, 0.999)`). Both the fill table and the `sampleFrom` inverse-CDF
branch now fall back to the per-lane sampler when that value is zero. Before
the fix, `VectorBinomial(128, 0.999)` returned 128 for every lane.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216`
rows (ScalarPrng):

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `fillVectorBinomial large u64x4 n=200 p=0.4` | 16.3 M lanes/s | 90.2 M lanes/s | +5.5x |
| `... large u64x4 direct n=200 p=0.4` | 16.8 M lanes/s | 95.6 M lanes/s | +5.7x |
| `... VectorBinomial.fill large u64x4 n=200 p=0.4` | 16.4 M lanes/s | 90.7 M lanes/s | +5.5x |
| `fillVectorBinomial mid u64x4 n=100 p=0.4` | 112.6 M lanes/s | 112.6 M lanes/s | unchanged |
| `alea fillVectorBinomial non-dyadic f64x4` (40, 0.4) | 83.0 M lanes/s | 83.0 M lanes/s | unchanged |

The candidate row `fillVectorBinomial cdf-binary u64x4 n=200 p=0.4` measures
93.6M lanes/s, matching production. A threshold sweep showed the binary
search loses at width 100 (87-91M versus 112M for the scan) and wins at 200,
so the switch stays at 128.

## Distribution Audit

Scratch fill audit (100k vectors = 400k lanes per case, exact `Binomial.cdf`):

| Case | Mean | Exact mean | max abs CDF error |
| --- | --- | --- | --- |
| (100, 0.4) | 40.016 | 40.000 | 0.00124 |
| (200, 0.4) | 80.022 | 80.000 | 0.00150 |
| (1024, 0.4) | 409.652 | 409.600 | 0.00170 |
| (128, 0.999) | 127.872 | 127.872 | 0.00014 |
| (64, 0.999) | 63.937 | 63.936 | 0.00140 |

`tools/distcheck.zig` now gates `VectorBinomial(200, 0.4)` CDF at `76`, `80`,
and `84`, and `VectorBinomial(128, 0.999)` CDF at `127`.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native 950/950).
- `zig build distcheck --summary all`: 5/5 steps and 2/2 tests with the new
  gates.

## Changed Files

- `src/distributions.zig`: 1024-entry fill table, binary-search fill kernel,
  and the extreme-`p` fallback guards.
- `bench/vector.zig`: lambda-100/200 binomial fill rows and the binary-search
  candidate row.
- `tools/distcheck.zig`: large/extreme binomial fill CDF gates.
- `compare/results/reproducibility-matrix.md`: records the bulk fill policy
  and the extreme-`p` fix.
