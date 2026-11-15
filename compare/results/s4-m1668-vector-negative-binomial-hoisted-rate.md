# S4-M1668 Vector Negative-Binomial Hoisted Log Rate

Date: 2026-11-16

## Change

`VectorNegativeBinomial.sample`/`sampleFrom` called `negativeBinomialFrom` per
lane, which recomputes `q = -log(1 - p)` for every lane, and the fill paths did
the same per vector. The scalar `NegativeBinomial.fill` already hoists `q`
across the slice (S4-M1453). The vector paths now mirror that dispatch:

- `p == 0.5` with `successes < 2^20`: per-lane fair clz sum,
- `successes >= 2^20`: per-lane gamma-Poisson mixture,
- otherwise: one `q` per vector for `sampleFrom` (one per slice for
  `fillFrom`) and `negativeBinomialFromLogQ` per lane.

`sample`/`fill` delegate to `sampleFrom`/`fillFrom`, and the per-lane kernel
and draw order are unchanged, so all checksums are identical.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728`
runs, bracketed A/B in both orders:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea vector negative-binomial f64x4` (5, 0.4) | 26.7-28.2 M vectors/s | 28.3-28.9 M vectors/s | +2.5-6% |
| `alea vector negative-binomial dyadic f64x4` (5, 0.25) | 27.8-28.1 M vectors/s | 28.8 M vectors/s | +2.5-3.6% |
| `alea fillVectorNegativeBinomial f64x4` (5, 0.4) | 33.9-34.0 M vectors/s | 34.3-34.4 M vectors/s | +1.2% |

Checksums are unchanged (`125814305.000`, `251697422.000`, `125804144.000`).
The scalar `alea negative-binomial` (151.7-152.4 M) and fair (318.6-322.6 M)
rows are unchanged. The win is small because the log is amortized over the
per-success geometric draws; the fill path was already close to its draw cost.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native `alea-tests` 950/950), including the vector negative-binomial
  fill-vs-loop stream tests.

## Changed Files

- `src/distributions.zig`: hoisted dispatch and log rate in
  `VectorNegativeBinomial`.
- `bench/throughput.zig`: the `alea fillVectorNegativeBinomial f64x4` row.
- `compare/results/performance-triage.md`: records the adoption.
- `compare/results/reproducibility-matrix.md`: records the stream-preserving
  speedup.
