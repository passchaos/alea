# S4-M1650 Vector Binomial Inverse-CDF Kernel

Date: 2026-11-15

## Change

Non-dyadic `p` with small trials still fell back to per-lane scalar draws
(6.1 M vectors/s for trials=40, p=0.4). Added
`vectorBinomialInverseCdfFrom`: for `trials <= 64` it computes the binomial
CDF once per call (pmf recurrence from `(1-p)^n`), draws one open uniform per
lane, and counts `u > F(k)` with `trials` vector compares. `sampleFrom`
dispatches to it after the fair and dyadic paths.

## Measurements (same-period A/B)

| Row | Per-lane scalar draws | Inverse-CDF kernel | Change |
| --- | --- | --- | --- |
| `alea vector binomial non-dyadic f64x4` (40, 0.4) | 6.1 M | 22.9 M | +275% |
| `alea vector binomial f64x4` (40, 0.25) | 100.5-106.2 M | 100.5-106.2 M | unchanged |
| `alea vector binomial fair f64x4` (40, 0.5) | 224.9-233.3 M | 224.9-233.3 M | unchanged |
| `alea vector binomial large f64x4` (256, 0.25) | 28.7-28.9 M | 28.7-28.9 M | unchanged |

The non-dyadic checksum changes `33546658.000` -> `33560335.000` (inverse-CDF
stream instead of per-lane scalar draws) and is versioned in
`reproducibility-matrix.md`.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native `alea-tests` 950/950).

## Changed Files

- `src/distributions.zig`: `vectorBinomialInverseCdfFrom` and the dispatch.
- `bench/throughput.zig`: the `alea vector binomial non-dyadic f64x4` row.
- `compare/results/performance-triage.md`: records the adoption.
- `compare/results/reproducibility-matrix.md`: versions the stream.
