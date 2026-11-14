# S4-M1560 One-Setup Inverse-CDF Walk Fill

Date: 2026-11-15

## Gap

After S4-M1556 routed `binomialFrom` through the one-uniform inverse-CDF
walk, `Binomial.fill`/`fillFrom` still called `binomialFrom` per element in
the `mean < 16` region, recomputing `px0 = exp(n·log1p(−p))` and
`ratio = p/(1−p)` for every draw. Runtime-parameter fills therefore ran at
about 24M samples/s even though the walk itself is fast.

## Change

- Split the walk into `binomialInversionDrawFrom(source, trials, px0, ratio)`
  and kept `binomialInversionWalkFrom` as the one-shot setup wrapper.
- Added an out-of-line `binomialFillInversionFrom` that computes the constants
  once and fills through `binomialInversionDrawFrom`, with the same
  `p > 0.5` flip as `binomialFrom`.
- `Binomial.fill`/`fillFrom` call it after the HIN helper; the
  fair/dyadic/per-trial/HIN regions are unchanged.
- Added `alea fillBinomial mean-12` and `alea fillBinomial mean-12 scalar
  direct` benchmark rows using the existing volatile mean-12 parameters.

## Probe

`zig build bench -Doptimize=ReleaseFast -- 16777216 "alea fillBinomial
mean-12"`, same host, best of three trials per row, before/after (the
baseline keeps the same benchmark rows but reverts the fill helper):

| Row | Before | After | Delta | Checksum |
| --- | --- | --- | --- | --- |
| `alea fillBinomial mean-12` | 23.7 M/s | 49.9 M/s | +110% | `788021` |
| `alea fillBinomial mean-12 scalar direct` | 24.9 M/s | 50.6 M/s | +103% | `788021` |

## Validation

- Identical checksums before/after confirm the stream-preserving claim: the
  constants are deterministic and the per-draw walk order is unchanged.
- `zig build test distcheck --summary all` passes 957/957 tests (native
  `alea-tests` 936/936), including the small-mean walk parity and moments
  tests.
- The new benchmark rows are in `bench/throughput.zig`; no build-step or
  example catalog changed.

The aggregate `validate-all` refresh is tracked as the following milestone.
