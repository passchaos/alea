# S4-M1334 — Long-run continuous CDF consistency gates

## Goal

Extend the S4-M1333 empirical-CDF validation to the continuous samplers that
previously had only moment or tail checks:

- Beta(2, 5) at x = 0.1, 0.3, 0.6,
- Gamma(shape = 2.5, scale = 1.5) at x = 1, 3, 5,
- StudentT(dof = 5) at x = −1, 0, 1.5,
- FisherF(5, 10) at x = 0.5, 1, 2.

## Implementation

`checkLongRun` draws all four families from one `FastPrng` stream and compares
each empirical rate with the sampler's `cdf(x)` method through
`expectEmpiricalCdf` at `±0.002` (about 4σ at 1,000,000 samples for p ≈ 0.5 and
12σ at 10,000,000). Using the sampler methods exercises both the reusable
sampler diagnostics and the underlying `betaCdf` / `gammaCdf` / `studentTCdf` /
`fisherFCdf` helpers. The long-run output prints one representative rate per
family.

## Observed 10,000,000-sample rates

| Gate | Empirical | Expected | Difference |
| --- | --- | --- | --- |
| beta(0.3) | 0.579665 | 0.579825 | −0.00016 |
| gamma(3) | 0.450547 | 0.450584 | −0.00004 |
| student-t(0) | 0.500212 | 0.500000 | +0.00021 |
| fisher-f(1) | 0.534822 | 0.534881 | −0.00006 |

All 12 gates pass at both 1,000,000 and 10,000,000 samples.

## Validation

- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)` in about 24 seconds; the four-family
  block adds roughly 15 seconds because Beta/Student-t/Fisher-F draw several
  gamma variates per sample.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 1000000` passes.
- `zig build distcheck` runs the tool tests (2/2), including the
  `expectEmpiricalCdf` boundary test.
- `zig build test` passes 888/888 with all doc gates.
- Discrete, tail, and copula rates are unchanged from S4-M1333.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
additional continuous families (inverse-Gaussian, skew-normal, rank
distributions), or newly discovered core gaps.
