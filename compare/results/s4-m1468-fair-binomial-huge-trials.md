# S4-M1468 HIN Fallback for Huge Fair Binomials

Date: 2026-11-14

## Problem

`binomialFrom` routed `p = 0.5` to the word-popcount fair path, which is
`O(trials/64)`: `binomial(1e9, 0.5)` took about 8 ms per draw and `1e18`
would run for years.

## Change

- Added `binomial_fair_max_trials = 4096`: below it the fair popcount path
  stays; above it `binomialFrom` uses a HIN setup that accepts `p = 0.5`
  (`binomialHinSetupHalf`), and `CachedBinomial` plus `Binomial.fill` follow
  the same threshold.
- The strict `binomialHinSetup` still rejects `p >= 0.5`, so the multinomial
  lead/second-conditional caches and their fair fast path are unchanged.
- The HIN setup/acceptance reuse the existing stable huge-trial path.

## After

| trials | path | ns/sample | mean ratio |
| --- | --- | --- | --- |
| 4096 | fair | 34.5 | 1.000041 |
| 4097 | HIN | 35.1 | 0.999994 |
| 1e9 | HIN | 19.9 | 1.000000 |
| 1e18 | HIN | 19.7 | 1.000000 |

`CachedBinomial(1e18, 0.5)` and `fillBinomial(1e6, 0.5)` means also match.

## Validation

- New `binomial fair path switches to HIN for huge trials` test covers the
  1e9/1e18 means, the cached sampler, and a bulk fill.
- `zig build test --summary all` passes 916/916 tests (native `alea-tests`
  897/897), `distcheck`, `statcheck`, and the 10M long run pass, and the full
  16MiB benchmark suite keeps all 457 checksums identical.
