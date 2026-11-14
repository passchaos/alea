# S4-M1412 — Waiting-time dispatch for small-mean binomial

## Goal

Select the cheaper exact binomial algorithm for small means. `binomialFrom`
previously sent every `mean >= 8` draw through the HIN rejection loop, but
the HIN envelope is tuned for larger means and the exponential waiting-time
method is faster below roughly mean 16.

## Evidence

Probe: HIN versus waiting-time crossover on the local aarch64 host (1M draws
per cell, best of runs, ns per draw; the waiting column hoists the
`-log(1-p)` that the library pays per call):

| trials | mean | HIN ns | waiting ns |
| --- | --- | --- | --- |
| 100 | 12 | 58.7 | 32.6 |
| 100 | 16 | 30.2 | 34.0 |
| 1000 | 12 | 46.3 | 29.5 |
| 1000 | 16 | 43.3 | 34.1 |
| 1000 | 20 | 41.5 | 38.7 |
| 10000 | 12 | 60.6 | 29.1 |
| 10000 | 16 | 43.6 | 34.1 |
| 10000 | 20 | 41.6 | 38.9 |

The crossover sits near mean 14-19 depending on `trials`; a single
conservative threshold of 16 keeps both sides within a few percent of the
per-cell optimum.

A HIN iteration probe (copied loop verified against `binomialFrom` by exact
checksum equality) shows why small means lose: `n = 100, p = 0.4` averages
1.49 candidates per draw, `n = 100, p = 0.1` 2.10, `n = 1000, p = 0.4` 1.15,
and `n = 10000, p = 0.01` 1.36, while the waiting-time method costs one
exponential per expected success.

## Change

`binomialSmallPFrom` and `binomialHinSetup` now share the named threshold
`binomial_hin_min_mean = 16.0`. Below it, `binomialFrom` uses the exact
exponential waiting-time method that already served `mean < 8`; at or above
it, the HIN rejection loop is unchanged. Because `binomialHinSetup` returns
null in the same region, cached callers (`Multinomial`'s first conditional
and second-conditional cache) stay on the same dispatch.

## Results

Interleaved same-period A/B with two saved binaries (three alternating runs
each, medians):

- `alea binomial mean-12` (1000, 0.012): 20.6-21.1M -> 33.4-34.9M samples/s
  (+60-66%), checksum shifts from `788546` to `785832` because the stream
  shape changes for the affected parameter region.

Unchanged rows (identical checksums, throughput within noise):

- `alea binomial` (dyadic) 885-900M `2623275`,
- `alea binomial 3/8` 195-218M `3930958`,
- `alea binomial 1/16` 154-155M `656003`,
- `alea binomial large` 33.6-33.9M `6553076`,
- `alea binomial poisson approx` 123-139M `6556077`,
- `alea negative-binomial` 172-184M `982200`,
- `alea beta binomial` 51.0-52.5M `2097245`,
- `alea multinomial` 8.2-8.5M `546091`, direct 9.1-9.4M `545072`,
  many direct 11.0-11.5M `545072`.

The reusable `Binomial` sampler gains the same dispatch because it delegates
to `binomialFrom` outside the dyadic path.

## Rejected probe

Caching the HIN setup in the reusable `Binomial` sampler (the pattern
`Multinomial` uses) was probed and rejected. With literal benchmark
parameters the facade's setup is already constant-folded, so a cached
sampler only pays for the larger value: the new `alea binomial large
sampler` row measured 27.2-27.6M against 29.8-30.4M samples/s for the
16-byte struct (~8-10% slower). With runtime parameters the cached setup is
about 2x faster (58-79 ns against 26-47 ns across a parameter grid), but
serving that case would need a dedicated cached sampler type instead of
growing `Binomial`.

## Validation

- `zig build test --summary all` passes 902/902, including the new
  `binomial waiting-time region has plausible moments` test (200,000 samples
  for `(1000, 0.012)` and `(100, 0.12)`),
- `zig build distcheck` and `zig build statcheck` pass,
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.

## Next bar

Broader platform runners, medium-mean binomial envelope work (BTPE-style
central rejection), or newly discovered core gaps.
