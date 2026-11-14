# S4-M1453 Shared Negative-Binomial Fill Rate

Date: 2026-11-14

## Gap

`NegativeBinomial.fill` and `fillFrom` looped `negativeBinomialFrom`, which
recomputes `q = -log(1 - p)` for every element. The direct-source fill was
still paying that log per element; the facade fill already had it hoisted by
the inliner.

## Change

- Extracted `negativeBinomialFromLogQ`, the success loop with a caller-provided
  `q`; `negativeBinomialFrom` now computes `q` once and delegates to it.
- `NegativeBinomial.fill` and `fillFrom` compute `q` once per fill and loop the
  kernel.
- A new `negative binomial fill matches repeated sampling` test compares both
  fill paths against repeated `negativeBinomial` / `negativeBinomialFrom` draws
  for `(5, 0.4)`.

## Benchmark

16Mi samples, three interleaved A/B rounds:

| Row | Baseline | Shared rate | Delta |
| --- | --- | --- | --- |
| `alea fillNegativeBinomial` | 159.3-162.1M samples/s | 160.1-161.4M | parity |
| `alea fillNegativeBinomial scalar direct` | 180.4-182.4M | 189.7-190.9M | +4-5% |

Sensitive rows (`negative-binomial`, `geometric`, `beta binomial`) stay at
parity with unchanged checksums.

## Validation

- `zig build test --summary all` passes 910/910 tests (native `alea-tests`
  891/891), including the new fill-parity test.
- `distcheck`, `statcheck`, and the 10M long run
  (`distlongcheck ok (10000000 samples)`) pass.
- The full 16MiB benchmark suite keeps all 456 checksums identical.
