# LogNormal Transform Notes

This note captures the current evidence for LogNormal performance work. The
remaining gap is not in normal generation or sampler dispatch; it is in the
floating-point transform from log-space normal samples to output samples.

## Current Baseline

Production LogNormal sampling uses the exact conceptual shape:

- generate a normal sample in log space,
- apply `@exp`.

Bulk fills stage normal samples into the destination slice and apply the
transform in place. Current evidence shows:

- f64 fill is around 133M samples/s for facade/FastPrng direct and around
  140M for ScalarPrng direct,
- f32 fill is around 132M for facade/FastPrng direct and around 141M for
  ScalarPrng direct,
- normal-only fill is much faster, so the bottleneck is the transform.

Local `rand_distr 0.6.0` uses the same high-level algorithm:
`Normal.sample(rng).exp()`.

## Rejected Or Deferred Transform Shapes

- Wrapper inlining does not close the gap.
- Direct field storage in the reusable sampler does not close the gap.
- Normal generation is not the bottleneck.
- `@mulAdd` in the single-sample expression does not win.
- `exp2(x * log2e)` regresses.
- `std.math.exp` is tied with `@exp`.
- `@setFloatMode(.optimized)` is tied/mixed and not a no-regression win.
- f32 vector width changes do not produce a durable win.
- f32 `expm1(x) + 1` can be faster for narrow `stddev = 0.25`, but changes
  output rounding; max error is 1 ULP for the narrow benchmark and grows
  substantially for wider spreads.
- A branchy f32 hybrid can keep wider-parameter error near 1 ULP, but the
  branch cost is too high for the measured fill workload.

## Requirements For A Future Change

A future LogNormal transform change should satisfy at least one of:

1. It is bit-identical or demonstrably distribution-equivalent with an explicit
   versioned-output note.
2. It is exposed as an opt-in sampler/fill variant with clearly documented
   accuracy and reproducibility tradeoffs.
3. It improves both f32 and f64, or is narrowly scoped to f32 with parameter
   bounds that prevent the wider-`stddev` error growth observed in probes.

Any candidate should be measured in both `log-normal-probe` and the main
throughput harness before replacing production behavior.
