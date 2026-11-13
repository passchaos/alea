# S4-M1333 — Long-run discrete CDF consistency gates

## Goal

Validate the discrete samplers beyond their means by comparing 10,000,000-sample
empirical CDFs against the discrete CDF helpers, including the S4-M1330
hypergeometric CDF:

- Binomial(20, 0.3) at k = 4, 6, 8,
- Poisson(λ = 5) at k = 3, 5, 8,
- Hypergeometric(100, 30, 10) at k = 2, 3, 5,
- NegativeBinomial(3, 0.5) at k = 1, 3, 6,
- Geometric(0.4) at k = 1, 2, 4.

## Implementation

`checkLongRun` adds one loop that draws all five families from the same
`FastPrng` stream and counts the threshold hits. `expectEmpiricalCdf` compares
the empirical rate with the sampler's `cdf(k)` using a fixed `±0.002` band
(about 4σ at 1,000,000 samples for p ≈ 0.5 and 12σ at 10,000,000). The long-run
output prints one representative rate per family. A unit test covers the helper's
exact, boundary, and out-of-band behavior.

## Observed 10,000,000-sample rates

| Gate | Empirical | Expected | Difference |
| --- | --- | --- | --- |
| binomial(4) | 0.237659 | 0.237508 | +0.00015 |
| poisson(5) | 0.615994 | 0.615961 | +0.00003 |
| hypergeometric(2) | 0.373045 | 0.372857 | +0.00019 |
| negative-binomial(3) | 0.656439 | 0.656250 | +0.00019 |
| geometric(2) | 0.639865 | 0.640000 | −0.00014 |

All 15 gates pass at both 1,000,000 and 10,000,000 samples.

## Validation

- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)` in about 9.3 seconds; the extra five
  million sampler draws add under one second.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 1000000` passes.
- `zig build distcheck` runs the tool test binary (2/2), including the new
  `empirical cdf helper` boundary test.
- Tail and copula rates are unchanged from S4-M1332.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
continuous-distribution goodness-of-fit bins, or newly discovered core gaps.
