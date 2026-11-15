# S4-M1646 Vector Fair Binomial Kernel

Date: 2026-11-15

## Change

The dyadic vector binomial kernel only covered `m >= 2` probabilities, so
`p = 0.5` fell back to per-lane scalar draws (95.3-95.7 M vectors/s for
trials=40). Added `vectorBinomialFairFrom`: every bit is a trial, so up to 64
trials are one word popcount per lane, with extra rounds for larger trials.
`VectorBinomial.sampleFrom` dispatches `p == 0.5` to it before the dyadic
path.

## Measurements (same-period A/B)

| Row | Per-lane scalar draws | Vector fair kernel | Change |
| --- | --- | --- | --- |
| `alea vector binomial fair f64x4` (40, 0.5) | 95.3-95.7 M | 215.1-233.9 M | +125-145% |
| `alea vector binomial f64x4` (40, 0.25) | 98.3-109.0 M | 98.3-107.3 M | unchanged |
| `alea vector binomial large f64x4` (256, 0.25) | 27.9-28.2 M | 27.9-28.2 M | unchanged |

The fair-row checksum is unchanged (`41951559.000`) because both paths consume
one word per lane and count the same bits; the dyadic and large rows keep
their versioned checksums.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native `alea-tests` 950/950).

## Changed Files

- `src/distributions.zig`: `vectorBinomialFairFrom` and the `p == 0.5`
  dispatch.
- `bench/throughput.zig`: the `alea vector binomial fair f64x4` row.
- `compare/results/performance-triage.md`: records the adoption.
- `compare/results/reproducibility-matrix.md`: notes the fair vector path.
