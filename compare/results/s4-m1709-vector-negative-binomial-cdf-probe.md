# S4-M1709 Vector Negative-Binomial CDF Probe (Rejected)

Date: 2026-11-16

## Probe

After the binomial/Zipf/hypergeometric windowed-CDF wins, tested the same
shape on `VectorNegativeBinomial.fillFrom` for the non-fair, non-mixture
range: build a `mean +/- 10 sigma` windowed CDF table once per slice and draw
each lane with one uniform plus a branchless vector scan, falling back to
`negativeBinomialFromLogQ` for the tails. For `(5, 0.25)` the window is
about 83 entries.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216
"NegativeBinomial"` (ScalarPrng):

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `fillVectorNegativeBinomial u64x4 r=5 p=0.25` (facade) | 120.0 M lanes/s | 97.3 M lanes/s | -19% |
| `... direct` | 164.2 M lanes/s | 109.2 M lanes/s | -33% |
| `VectorNegativeBinomial.fill u64x4` | 117.5 M lanes/s | 95.1 M lanes/s | -19% |

The 83-entry scan costs more per vector than the five per-success geometric
draws the logQ kernel already performs, so the windowed CDF shape loses here.
The change was reverted.

## Decision

Rejected. `VectorNegativeBinomial` keeps the per-success logQ fill and the
existing stream. No code change remains.

## Lesson

The windowed-CDF fill wins when the support width is small (the binomial
window for `(10000, 0.01)` is about 200 but the HIN kernel is expensive) or
when the per-lane kernel is costly (rejection-inversion with logs); it loses
against cheap per-success sums such as `negativeBinomialFromLogQ` with small
`successes`.

## Changed Files

- `compare/results/performance-triage.md`: records the rejection.
