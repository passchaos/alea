# S4-M1696 Vector Hypergeometric CDF Scan

Date: 2026-11-16

## Change

`VectorHypergeometric` sampled the inverse-transform method lane-by-lane
with the scalar pmf walk. For support widths up to 32 it now builds the
cumulative pmf once per call (or once per fill) from the cached
`HypergeometricInverseTransform` fields and draws each lane with one uniform
plus a branchless vector scan, mirroring the vector binomial/Zipf kernels.
Wider supports and the other methods keep the per-lane kernels.

The scan and the walk implement the same inverse-CDF mapping for the same
uniform, so the throughput checksum is unchanged. The fill-vs-loop test also
passes because the vector sample path uses the same scan.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native` runs:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `vectorbench fillVectorHypergeometric u64x4` (facade) | ~72 M lanes/s | 419.3 M lanes/s | ~5.7x |
| `vectorbench ... direct` | ~76 M lanes/s | 557.5 M lanes/s | ~7.6x |
| `vectorbench VectorHypergeometric.fill u64x4` | ~72 M lanes/s | 446.3 M lanes/s | ~6x |
| `bench alea vector hypergeometric f64x4` | 18-19 M vectors/s | 68.5 M vectors/s | ~3.6x |

The throughput checksum is unchanged (`6295352.000`), confirming the
stream-preserving inverse-CDF mapping.

## Distribution Audit

Scratch vector fill audit (400k lanes per case, exact `Hypergeometric.cdf`):

| Case | Mean | Exact mean | max abs CDF error |
| --- | --- | --- | --- |
| (100, 30, 10) | 2.9998 | 3.0000 | 0.00065 |
| (50, 5, 10) | 1.0002 | 1.0000 | 0.00049 |
| (200, 20, 8) | 0.8001 | 0.8000 | 0.00029 |

`tools/distcheck.zig` now gates `VectorHypergeometric(100, 30, 10)` CDF at
`2`, `3`, and `5` over 800k lanes.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native 950/950), including the vector hypergeometric fill-vs-loop
  test.
- `zig build distcheck --summary all`: 5/5 steps and 2/2 tests.

## Changed Files

- `src/distributions.zig`: `hypergeometricCdfTable`,
  `vectorHypergeometricFromCdf`, and the `VectorHypergeometric`
  sample/fill dispatch.
- `tools/distcheck.zig`: vector hypergeometric CDF gates.
- `compare/results/reproducibility-matrix.md`: records the stream-preserving
  speedup.
