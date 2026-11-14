# S4-M1394 — Packed dyadic binomial trials

## Goal

Speed up small-trial binomial sampling for dyadic probabilities by packing
several Bernoulli trials into each engine word and counting successes with a
single SWAR popcount, instead of one word per trial.

## Implementation

- `dyadicBinomialFields` decomposes a dyadic `p = k / 2^m` (k odd) from the
  f64 bit pattern and accepts the widths with SWAR kernels: `m = 2` with
  `k = 1` (p = 1/4) or `k = 3` (p = 3/4), and `m = 3` with `k = 1`
  (p = 1/8). Probabilities above 1/2 are handled by the existing complement
  flip.
- `binomialDyadicFrom` treats each word as 32 (m = 2) or 21 (m = 3) uniform
  fields. The success mask is computed with one AND/OR/shift chain per word
  (`~bits & ~(bits >> 1)` for p = 1/4, `~(bits & (bits >> 1))` for p = 3/4,
  `~(bits | (bits >> 1) | (bits >> 2))` for p = 1/8), and one popcount counts
  every trial in the word. Partial final words mask off the unused fields.
- `binomialDyadicTryFrom` wires the fast path into the top-level `binomial`
  facade and the reusable `Binomial.sample`, `sampleFrom`, `fill`, and
  `fillFrom` methods. `binomialFrom` itself is deliberately untouched: the
  first attempt hooked it there and cost `beta binomial` about 45% and
  `multinomial` about 10% because the extra branch pushed it over the
  inliner threshold, losing the devirtualized facade draws in those composed
  paths. The targeted hook keeps both compositions at their previous
  throughput.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea binomial` (n = 40, p = 0.25) | 66.3M samples/s | 898-907M samples/s | +1255% |
| `alea fillBinomial` | 64.9M samples/s | 751-754M samples/s | +1060% |
| `alea fillBinomial scalar direct` | 78.0M samples/s | 996-998M samples/s | +1180% |
| `alea beta binomial` | 52.5M samples/s | 53.4-53.7M samples/s | unchanged |
| `alea multinomial` | 8.3-8.5M samples/s | 8.4-8.5M samples/s | unchanged |
| `alea binomial large` | 33.1M samples/s | 33.1-33.2M samples/s | unchanged |

The sampled law is unchanged but the consumed stream differs, so the
checksums shift and are stable: `binomial` `2622744` → `2623275`,
`fillBinomial` `2623275`, and `fillBinomial scalar direct` `2619332`.
Non-dyadic probabilities (for example `1/6` or `0.4`) fall through to the
generic Bernoulli loop, and `beta binomial`'s random per-draw probability
therefore keeps the old path.

## Validation

- All 14 binomial-family tests pass, including the small-trial moment gates.
- `zig build test` passes 899/899, including `apicheck` and `roadmapcheck`.
- `zig build distcheck` passes (including the binomial mean/variance gate) and
  `zig build statcheck` passes.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners, further small-trial packing for other dyadic
shapes, or newly discovered core gaps.
