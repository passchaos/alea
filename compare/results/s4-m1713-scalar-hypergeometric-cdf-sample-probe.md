# S4-M1713 Scalar Hypergeometric CDF Sample Probe (Rejected)

Date: 2026-11-16

## Probe

After the S4-M1711 Zipf per-call CDF sample win, tested the same shape on
`Hypergeometric.sample`/`sampleFrom` for the inverse-transform method:
build the cumulative table per call (11 entries at `(100, 30, 10)`) and draw
with one uniform plus a binary search, falling back to the pmf walk for the
tail.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216
"alea hypergeometric"`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea hypergeometric` (100, 30, 10) | 71.3 M samples/s | 53.5 M samples/s | -25% |
| `alea hypergeometric large` | 33.1 M samples/s | 33.1 M samples/s | unchanged |
| `alea hypergeometric skew-large` | 34.2 M samples/s | 34.2 M samples/s | unchanged |

The inverse-transform walk starts near the lower support bound (the setup
only accepts `mode - lower_bound < 10`), so it is about three sequential
steps; the 11-term table build costs more than the walk. The change was
reverted.

## Decision

Rejected. `Hypergeometric.sample`/`sampleFrom` keep the pmf walk; the
S4-M1699 fill keeps the hoisted CDF table, where the build is amortized over
the whole slice.

## Lesson

A per-call CDF table wins only when the per-sample kernel is expensive
(Zipf rejection-inversion with a log/exp race); it loses against a short
sequential walk such as the hypergeometric inverse transform.

## Changed Files

- `compare/results/performance-triage.md`: records the rejection.
