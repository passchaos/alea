# S4-M1686 Scalar Poisson CDF Fill

Date: 2026-11-16

## Change

The scalar `Poisson.fill`/`fillFrom` product method (`lambda < 12`) drew each
sample with the sequential product loop. It now builds the same small Poisson
CDF table used by the vector fill once per call and draws each sample with one
uniform plus a binary search; a uniform above the last stored cumulative value
(the truncated `1e-15` tail) falls back to the exact product method. `sample`
keeps the product stream, so this is a documented scalar bulk-fill policy.
`lambda >= 12` keeps the Ahrens-Dieter path.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea fillPoisson small` (lambda=4) | 65.4 M samples/s | 270.2 M samples/s | 4.1x |
| `alea candidate fillPoisson small cdf` (probe) | - | 281.3 M samples/s | - |
| `alea fillPoisson` (lambda=20, Ahrens-Dieter) | 86.6 M samples/s | unchanged | - |

The production row includes the exact tail fallback; the probe omits it, so
the 270.2M production rate is the relevant number.

## Distribution Audit

Scratch fill audit (400k samples per case, exact `Poisson.cdf`):

| Lambda | Mean | Exact mean | max abs CDF error |
| --- | --- | --- | --- |
| 1.0 | 1.0005 | 1.0000 | 0.00058 |
| 4.0 | 4.0000 | 4.0000 | 0.00052 |
| 11.9 | 11.9026 | 11.9000 | 0.00001 |

`tools/distcheck.zig` now gates `fillPoisson(lambda=4)` CDF at `2`, `4`, and
`8` over 800k samples.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native 950/950).
- `zig build distcheck --summary all`: 5/5 steps and 2/2 tests with the new
  gates.

## Changed Files

- `src/distributions.zig`: `poissonFromCdfTable` and the product-method fill
  branches.
- `bench/throughput.zig`: `alea fillPoisson small` and the CDF probe row.
- `tools/distcheck.zig`: `fillPoisson` CDF gates.
- `compare/results/reproducibility-matrix.md`: records the versioned scalar
  fill stream.
