# S4-M1456 Negative-Binomial Q-Cache Probe

Date: 2026-11-14

## Question

`NegativeBinomial.sample`/`sampleFrom` call `negativeBinomialFrom`, which
computes `q = -log(1 - p)` on every draw. Does caching `q` in the sampler
struct speed up runtime-parameter callers?

## Probe

Temporarily added a `q` field computed in `init`, used it in
`sample`/`sampleFrom`/`fill`/`fillFrom`, and added the
`alea negative-binomial runtime` row with volatile `(5, 0.4)` parameters.

## Measurements

16Mi samples, same binary layout apart from the probe:

| Row | Baseline (recomputed `q`) | Cached `q` |
| --- | --- | --- |
| `alea negative-binomial` (literal) | 166.1M samples/s | 159.5M (-4%) |
| `alea negative-binomial runtime` | 160.3M samples/s | 154.3M (-4%) |

## Finding

The inliner already hoists the loop-invariant `-log(1 - p)` out of repeated
`sample` calls, so the explicit cache only grows the sampler value from 16 to
24 bytes and adds copy cost. After reverting, the runtime row stays at 161.4M,
at parity with the 164.7M literal row.

## Decision

Not adopted. The sampler keeps its 16-byte layout, and the new runtime row is
kept as a regression guard for the hoisting behavior.
