# S4-M1382 — Degenerate HIN waiting tail and shared envelope log

## Goal

Remove deterministic work from the HIN small-`p` binomial path: skip the
waiting-tail exponential draw when the tail is provably zero, and derive both
envelope cut points from one shared log instead of two independent ones.

## Implementation

- `binomialHinSampleFrom` now returns `x_int` directly when `setup.q == 0`.
  `q = −log(1 − (p − pa)/(1 − pa))` is exactly zero when `p` equals
  `np / trials`, so the waiting-time tail always yields zero successes and the
  first Exp(1) draw could never change the result. The sampled law is
  unchanged; only the consumed random stream differs for that branch.
- `binomialHinSetup` derives both cut-point arguments from one shared log:
  with `A = log(32·t/(π/4))` and `L = log(pa/(1−pa))`, the first argument is
  `A − log 81 + L` and the second is `A − L`. `L` is the same log the
  acceptance term already needed (`lp1p`), so the setup drops from four logs
  to two.
- A probe compared every `BinomialHinSetup` field bit-for-bit against the old
  expressions over 1,379,339 `(trials, p)` pairs: the full `trials = 65..2048`
  sweep with `p` from `8/trials` to `0.5`, large-`n` spot checks at
  `trials ∈ {2049, 4096, 10000, 12345, 65535, 1000000}` with
  `p ∈ {0.0001..0.49}`, and the exact multinomial conditional probabilities
  `1/6` and `0.4` for every `trials` in `65..512`. All fields, including the
  rounded `d1`/`d2` cut points, matched exactly.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea binomial large` | 28.6-28.8M samples/s | 32.2-32.7M samples/s | +12.7% |
| `alea multinomial` | 8.1M samples/s | 8.0-8.1M samples/s | within noise |
| `alea multinomial direct` | 9.1-9.2M samples/s | 9.0-9.1M samples/s | within noise |
| `alea multinomial many direct` | 11.6-11.8M samples/s | 11.1-11.7M samples/s | within noise |

The `binomial large` row (`trials = 10_000`, `p = 0.01`) has `p == np/trials`
exactly, so every sample used to pay one exponential draw plus the tail call
and loop before returning zero. The new checksum is `6553076` and is stable
across runs. The multinomial checksums shift from `545523`/`545062` to
`546091`/`545072` because second-conditional draws whose remaining trial count
lands on the `0.4` grid (`70/75/80/85/90/95`) now skip the degenerate tail
draw; the sampled law is unchanged, and the row throughput stays inside the
run-to-run band.

## Validation

- All 14 binomial-family tests and all 3 multinomial tests pass.
- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners, `Rng` facade-overhead reduction for the facade
binomial/multinomial rows, or newly discovered core gaps.
