# S4-M1716 Vector Binomial Cached CDF

Date: 2026-11-16

## Change

`VectorBinomial.sampleFrom` rebuilt the non-dyadic inverse-CDF table on
every call for supports up to 1024 trials, leaving the per-vector sample rows
at 5.7-23.2M vectors/s while the hoisted fills reached 90-112M lanes/s. The
sampler now caches the cumulative table in `init` for non-dyadic, non-fair
supports up to 256 trials (2KB per instance); `sample`/`sampleFrom` and the
fills use the cached table with the same scan/binary thresholds as before.
Larger supports keep the per-call table (129..1024 trials) or the per-lane
sampler.

The sampler methods now take `*const Self` so the 2KB table is not copied
per call.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea vector binomial non-dyadic f64x4` (40, 0.4) | 23.2 M vectors/s | 65.7 M vectors/s | 2.8x |
| `alea vector binomial mid f64x4` (100, 0.4) | 8.9 M vectors/s | 24.3 M vectors/s | 2.7x |
| `alea vector binomial large-nondyadic f64x4` (200, 0.4) | 5.7 M vectors/s | 20.6 M vectors/s | 3.6x |
| `alea vector binomial f64x4` (40, 0.25, dyadic) | ~94 M vectors/s | ~91-95 M vectors/s | unchanged/noise |
| `alea vector binomial fair f64x4` (40, 0.5) | ~196 M vectors/s | ~194-196 M vectors/s | unchanged |
| `alea vector binomial large f64x4` (256, 0.25, dyadic) | 28.1 M vectors/s | 28.6 M vectors/s | unchanged |

All checksums are unchanged (`20963148.000`, `33560335.000`, `83891169.000`,
`167769239.000`, `41951559.000`, `134225536.000`), confirming the cached
table returns the same values as the per-call build.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 974/974
  tests (native 951/951), including the fill-vs-loop tests.
- `zig build roadmapcheck doccheck apicheck readmecheck --summary all`:
  26/26 steps and 19/19 tests.

## Changed Files

- `src/distributions.zig`: `binomialCdfTable` slice signature, the
  `VectorBinomial` cached table, and the `*const Self` receivers.
- `compare/results/reproducibility-matrix.md`: records the stream-preserving
  speedup.
