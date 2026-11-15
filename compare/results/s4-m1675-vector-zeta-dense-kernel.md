# S4-M1675 Dense Vector Zeta Kernel

Date: 2026-11-16

## Change

`VectorZeta` filled f64 vectors by calling the scalar rejection-inversion
kernel lane-by-lane, leaving the real vector-slice rows at about 128-158M
lanes/s against roughly 250M samples/s for the scalar sampler. Added
`vectorZetaDenseFrom`: one full-lane inverse-CDF attempt with vector math,
then the scalar rejection-inversion continuation only for rejected lanes. The
proposal and acceptance test are the same kernel, so the target law is
unchanged.

The dense path covers f64 vectors with `exponent - 1` in `{0.25, 0.5, 1, 2}`
(exponents `1.25`, `1.5`, `2`, and `3`), where the inverse CDF is a
vectorizable reciprocal, square root, or square. f32 vectors, other
exponents, and degenerate exponents keep the per-lane scalar stream.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216
"Zeta"` rows (ScalarPrng):

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea distributions.fillVectorZeta f64x4` | 127.8 M lanes/s | 212.3 M lanes/s | +66% |
| `... fillVectorZeta f64x4 direct` | 158.7 M lanes/s | 348.6 M lanes/s | +120% |
| `alea distributions.VectorZeta.fill f64x4` | 131.2 M lanes/s | 208.8 M lanes/s | +59% |
| `alea candidate fillVectorZeta dense f64x4` (probe row) | - | 371.0 M lanes/s | - |

The throughput harness row `alea vector zeta f64x4` (FastPrng, per-vector
`sample`, 128 MiB) moves from 32.0M vectors/s (128M lanes/s) to 63.9M
vectors/s (255.6M lanes/s), now at scalar parity (`alea zeta` 247.6-250.3M
samples/s). Checksums change because the dense stream shape is versioned; the
probe row keeps a distinct checksum because it calls the engine directly.

## Statistical Audit

Scratch probe with `FastPrng` seed `0x77aa`, 100,000 vectors (400,000 lanes)
per exponent, comparing the empirical CDF at `1`, `2`, `3`, and `4` with the
exact `Zeta.cdf`:

| Exponent | max abs error |
| --- | --- |
| 1.25 | 0.00050 |
| 1.50 | 0.00060 |
| 2.00 | 0.00038 |
| 3.00 | 0.00029 |

`tools/distcheck.zig` now also gates `VectorZeta(f64x4, exponent 3)` CDF at
`1`, `2`, and `4` in the discrete block.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native 950/950), including the vector zeta fill-vs-loop stream test
  (both paths use the dense kernel).
- `zig build distcheck --summary all`: 5/5 steps and 2/2 tests with the new
  vector zeta gates.

## Changed Files

- `src/distributions.zig`: `vectorZetaDenseSupported`,
  `vectorZetaDenseFrom`, and the dense `VectorZeta` sample/fill paths.
- `bench/vector.zig`: the dense zeta probe row.
- `tools/distcheck.zig`: vector zeta CDF gates.
- `compare/results/reproducibility-matrix.md`: records the versioned stream.
- `compare/results/simd-distribution-kernel-notes.md`: records the adopted
  dense discrete kernel.
