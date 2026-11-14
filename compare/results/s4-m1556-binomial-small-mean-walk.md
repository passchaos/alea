# S4-M1556 Small-Mean Binomial Inverse-CDF Walk

Date: 2026-11-15

## Gap

S4-M1447 added a one-uniform inverse-CDF walk to `CachedBinomial` and measured
it 44-51% faster than the exponential waiting-time race for means 1-15, but
kept it out of `binomialFrom` because the earlier inlined version cost
`beta-binomial` and `negative-binomial` through code layout. The literal
`Binomial` sampler (`binomial(rng, 1000, 0.012)`) therefore stayed on the
waiting race, which draws about `mean + 1` exponentials per sample.

## Change

- Added an out-of-line `binomialInversionWalkFrom` helper at the end of the
  production declarations. It computes `px0 = exp(n·log1p(−p))` and
  `ratio = p/(1−p)` and walks `px *= (n−k)/(k+1)·ratio` until `u < px`.
- `binomialSmallPFrom` now routes `mean < 16`, `trials > 64` draws through the
  walk instead of the waiting race. The `p == 0.5`, packed-dyadic,
  per-trial, and HIN regions are unchanged.
- `CachedBinomial` keeps the same walk and still precomputes its constants, so
  it remains the runtime-parameter path.
- The small-mean `Binomial` stream changes (the same walk, one uniform per
  draw); the `CachedBinomial` stream is unchanged.

## Probe

`zig build bench -Doptimize=ReleaseFast -- 16777216 "binomial"`, same host,
best of three trials per row, before/after:

| Row | Before | After | Delta | Checksum |
| --- | --- | --- | --- | --- |
| `alea binomial mean-12` (1000, 0.012) | 32.1 M/s | 50.7 M/s | +58% | `785832` → `786544` |
| `alea binomial runtime sampler mean-12` | 24.8 M/s | 23.6 M/s | noise | `787393` → `787277` |
| `alea binomial runtime cached mean-12` | 49.8 M/s | 50.3 M/s | parity | `787277` |
| `alea binomial large` | 33.1 M/s | 33.2 M/s | parity | `6552766` |
| `alea beta binomial` | 44.6 M/s | 44.5 M/s | parity | `2097245` |
| `alea negative-binomial` | 158.5 M/s | 166.7 M/s | noise | `982200` |

The runtime-parameter sampler row stays near 24M because it recomputes
`(1−p)^n` per draw; `CachedBinomial` remains the recommended runtime path at
about 50M. The literal row is the one that can constant-fold the parameters.

## Validation

- New `binomial small-mean walk matches the cached inversion stream` test:
  10,000 shared-seed draws for `(1000, 0.012)` and `(100, 0.12)` match
  `CachedBinomial` exactly, pinning the one-uniform walk contract.
- The existing `binomial small-mean ... moments` test (200k draws for
  `(1000, 0.012)` and `(100, 0.12)`, mean within 0.06 and variance within
  0.25) still passes.
- `zig build test distcheck --summary all` passes 957/957 tests (native
  `alea-tests` 936/936), including the multinomial/beta-binomial gates.
- `reproducibility-matrix.md` records the versioned small-mean stream change;
  the multinomial benchmark's conditional means stay above 16, so its rows
  and checksums are unchanged.

The aggregate `validate-all` refresh is tracked as the following milestone.
