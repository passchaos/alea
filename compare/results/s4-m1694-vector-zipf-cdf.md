# S4-M1694 Vector Zipf CDF Scan

Date: 2026-11-16

## Change

`VectorZipf` sampled every lane with the scalar rejection-inversion kernel.
For finite integer supports up to 32 it now builds the cumulative pmf once
per call (or once per fill) and draws each lane with one uniform plus a
branchless vector scan, mirroring the vector binomial CDF kernel. Larger,
infinite, or non-integer supports keep the rejection-inversion stream.

Added `zipfPmfTerm` with reciprocal fast paths for exponents `0.5`, `1`,
`1.5`, `2`, and `3`, replacing the generic `pow` per table entry in both the
scalar Zipf fill (S4-M1692) and the new vector path. The fast paths removed
the per-call table-build cost that otherwise dominated single-vector draws.

`sample`/`sampleFrom` and `fill`/`fillFrom` share the kernel, so the existing
vector Zipf fill-vs-loop test still passes.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native` runs:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `vectorbench fillVectorZipf f64x4` (facade) | 71.6 M lanes/s | 609.0 M lanes/s | 8.5x |
| `vectorbench fillVectorZipf f64x4 direct` | 60.1 M lanes/s | 533.6 M lanes/s | 8.9x |
| `vectorbench VectorZipf.fill f64x4` | 70.4 M lanes/s | 611.7 M lanes/s | 8.7x |
| `bench alea vector zipf f64x4` (per-vector sample) | 15.6 M vectors/s | 200.7 M vectors/s | 12.9x |
| `bench alea Zipf.fillFrom direct` (scalar) | 197.9 M samples/s | 200.3 M samples/s | unchanged |

Checksums change for the vector rows (`330159` -> `330116` in vectorbench,
`5272233` -> `5276228` in the sample row) because the vector Zipf stream is
versioned for `n <= 32`. The scalar fill checksum (`330202`) is unchanged.

## Distribution Audit

Scratch vector fill audit (400k lanes per case, exact `Zipf.cdf`):

| Case | Mean | max abs CDF error |
| --- | --- | --- |
| (10, 1.5) | 2.5167 | 0.00082 |
| (32, 1.5) | 4.3935 | 0.00087 |
| (33, 1.5, fallback) | 4.4766 | 0.00140 |
| (inf, 2.0, fallback) | 10.5521 | 0.00070 |

`tools/distcheck.zig` now gates `VectorZipf(10, 1.5)` CDF at `2`, `4`, and
`8` over 800k lanes.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native 950/950), including the vector Zipf fill-vs-loop test.
- `zig build distcheck --summary all`: 5/5 steps and 2/2 tests.

## Changed Files

- `src/distributions.zig`: `zipfPmfTerm`, `zipfVectorCdfTable`,
  `vectorZipfFromCdf`, and the `VectorZipf` sample/fill dispatch.
- `tools/distcheck.zig`: vector Zipf CDF gates.
- `compare/results/reproducibility-matrix.md`: records the versioned vector
  stream.
