# S4-M1699 Scalar Hypergeometric CDF Fill

Date: 2026-11-16

## Change

The scalar `Hypergeometric.fill`/`fillFrom` inverse-transform method walked
the pmf for every element. It now builds the same cumulative table used by
the S4-M1696 vector path once per call and draws each element with one
uniform plus a binary search; a uniform above the last stored cumulative
value falls back to the pmf walk. The table covers support widths up to 32.

The scan and the walk implement the same inverse-CDF mapping, so the fill
checksums are unchanged. `sample`/`sampleFrom` keep the walk.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea fillHypergeometric` (100, 30, 10) | 68-72 M samples/s | 119.2 M samples/s | ~1.7x |
| `alea fillHypergeometric scalar direct` | 75-80 M samples/s | 143.0 M samples/s | ~1.8x |
| `alea fillHypergeometric large` | 32.7 M samples/s | 32.7 M samples/s | unchanged |
| `alea fillHypergeometric skew-large` | 33.9 M samples/s | 33.9 M samples/s | unchanged |
| `alea hypergeometric` (sample) | 79.6 M samples/s | 79.6 M samples/s | unchanged |

The (100, 30, 10) fill checksums are unchanged (`393675` facade, `392632`
direct), confirming the stream-preserving inverse-CDF mapping. The
large/skew-large rows use other methods or wider supports and keep their
per-element kernels.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native 950/950).
- `zig build distcheck --summary all`: 5/5 steps and 2/2 tests, including the
  new `fillHypergeometric(100, 30, 10)` CDF gates at `2`, `3`, and `5` over
  800k samples.

## Changed Files

- `src/distributions.zig`: `hypergeometricFromCdfTable` and the scalar
  inverse-transform fill branches.
- `tools/distcheck.zig`: scalar hypergeometric fill CDF gates.
- `compare/results/reproducibility-matrix.md`: records the stream-preserving
  speedup.
