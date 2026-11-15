# S4-M1719 Vector Hypergeometric Cached CDF

Date: 2026-11-16

## Change

S4-M1696 made `VectorHypergeometric` build the inverse-transform CDF table
per call (or per fill). The sampler now builds the 32-entry table once in
`init` when the method is `.inverse_transform` and reuses it in
`sample`/`sampleFrom`/`fill`/`fillFrom`; wider supports and the other methods
keep their per-lane kernels.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native` runs:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `bench alea vector hypergeometric f64x4` (100, 30, 10) | 68.5 M vectors/s | 157.8 M vectors/s | 2.3x |
| `vectorbench fillVectorHypergeometric u64x4` (facade) | 419.3 M lanes/s | 442.5 M lanes/s | +5.5% |
| `vectorbench ... direct` | 557.5 M lanes/s | 610.7 M lanes/s | +9.5% |
| `vectorbench VectorHypergeometric.fill u64x4` | 446.3 M lanes/s | 453.3 M lanes/s | +1.6% |

The checksums are unchanged (`6295352.000` in the throughput harness and
`6292414` in vectorbench), confirming the cached table returns the same
values.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 974/974
  tests (native 951/951), including the vector hypergeometric fill-vs-loop
  test.

## Changed Files

- `src/distributions.zig`: the `VectorHypergeometric` cached table and the
  sample/fill dispatch.
- `compare/results/reproducibility-matrix.md`: records the stream-preserving
  speedup.
