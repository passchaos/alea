# S4-M1400 — Dyadic fraction coverage and Cauchy quantile gate

## Goal

Extend the packed dyadic binomial fast path to `p = 3/8` and `p = 1/16`, and
harden the ratio-of-normals Cauchy sampler with a distributional gate.

## Implementation

- `dyadicBinomialFields` now accepts `m = 3` with `k = 3` (p = 3/8) and
  `m = 4` with `k = 1` (p = 1/16) in addition to the existing `m = 2`
  (`k = 1, 3`) and `m = 3` (`k = 1`) shapes.
- `binomialDyadicFrom` adds the matching SWAR masks: `~(bits | bits>>1 |
  bits>>2)` for p = 1/8, `~((bits >> 2) | (bits & (bits >> 1)))` for p = 3/8,
  and `~(bits | bits>>1 | bits>>2 | bits>>3)` for p = 1/16. Each word packs 21
  (m = 3) or 16 (m = 4) trials and one popcount counts them.
- New benchmark rows `alea binomial 3/8` and `alea binomial 1/16` (n = 40)
  measure the new shapes, and a new unit test checks the mean and variance of
  both fractions over 100,000 samples.
- `tools/distcheck.zig` gains `checkCauchyQuantiles`: 100,000 standard Cauchy
  draws must satisfy `P(X ≤ 0) ∈ [0.494, 0.506]`, `P(X ≤ −1) ∈ [0.244, 0.256]`,
  and `P(X ≤ 1) ∈ [0.744, 0.756]`, gating the location and scale of the
  ratio-of-normals sampler where no finite mean exists. The check runs after
  all existing gates so no other stream segment moves.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea binomial 3/8` | 23.2-31.1M samples/s | 223.2-227.5M samples/s | +620-880% |
| `alea binomial 1/16` | 23.1-31.3M samples/s | 133.5-155.4M samples/s | +340-580% |

The sampled laws are unchanged; the consumed stream differs, so the checksums
shift and are stable (`3930958` for 3/8 and `656003` for 1/16). The existing
`alea binomial` (p = 0.25), `beta binomial`, `multinomial`, and `binomial
large` rows are unaffected.

## Rejected probes

- Four-normal unit ball projection: projecting four standard normals onto the
  first three coordinates gives density proportional to `(1 − r²)^{-1/2}`
  (the 2D analogue is the arcsine law), not the uniform ball density, so the
  method is invalid despite being about 3.7x faster in a probe.
- H2PE log-path exponential split: drawing the central-region acceptance value
  as `−Exp(1)` instead of `log(v)` cost the hypergeometric large rows about
  9% (33.2M versus 36.1M); the ziggurat exponential draw is more expensive
  than the avoided log, matching the earlier Bingham race result. Reverted.

## Validation

- All 15 binomial-family tests pass, including the new dyadic-fraction moment
  test.
- `zig build test` passes 900/900 (881 library tests plus 19 tool gates),
  including `apicheck` and `roadmapcheck`.
- `zig build distcheck` passes with the new Cauchy quantile gate; `zig build
  statcheck` passes.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig bench/throughput.zig
  tools/distcheck.zig` is clean.

## Next bar

Broader platform runners, packed fills for the 3/8 and 1/16 ratios, or newly
discovered core gaps.
