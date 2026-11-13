# S4-M1355 — HIN setup split and multinomial first-conditional cache

## Goal

Stop recomputing the HIN small-p binomial envelope constants on every draw:
split the constants from the rejection loop, simplify the setup algebra, and
cache the fixed first-conditional setup inside `Multinomial`.

## Implementation

- Extracted `BinomialHinSetup`, `binomialHinSetup`, and
  `binomialHinSampleFrom` from `binomialRejectionSmallPFrom`, which is now a
  thin wrapper. Proposal distributions, acceptance inequalities, waiting-time
  tail, and draw order are unchanged.
- Simplified the setup: one shared `sqrt(np * (1 - pa))`, `c / 8` instead of
  `d1 / (4 * np)`, and one combined exponential for the middle envelope term
  (`exp(a) * exp(b)` becomes `exp(a + b)`).
- `Multinomial` now caches the HIN setup for its first conditional binomial at
  `init`, together with the `p > 0.5` flip, and uses it in `sampleInto` /
  `sampleIntoFrom` when the first category is positive. Other categories and
  non-HIN parameter regimes keep the existing `binomialFrom` path.
- The cache reuses the same constants and draw sequence, so the sampled
  stream is unchanged.

## Benchmarks (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

Same-host focused A/B runs at the previous commit and with the change:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea multinomial` | 6.2M samples/s | 7.6M samples/s | +23% |
| `alea multinomial direct` | 6.6M samples/s | 8.0M samples/s | +21% |
| `alea multinomial many direct` | 6.6M samples/s | 8.1M samples/s | +23% |
| `alea binomial large` (`n = 10000`) | 11.1M samples/s | 19.6M samples/s | +77% |
| `alea beta binomial` | 43.4M samples/s | 53.0M samples/s | +22% |

Every benchmark checksum is identical before and after the change
(`multinomial` `546367` / `546657`, `binomial large` `6551447`,
`beta binomial` `2097245`), confirming the stream is preserved. The
`beta binomial` row uses the `n ≤ 64` Bernoulli path rather than HIN, so its
gain is code-layout sensitivity rather than an algorithmic claim.

## Validation

- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further multinomial batch specialization, or newly discovered core gaps.
