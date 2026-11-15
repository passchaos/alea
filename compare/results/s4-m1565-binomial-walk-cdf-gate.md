# S4-M1565 Small-Mean Binomial Walk CDF Gate

Date: 2026-11-15

## Gap

S4-M1556 moved the `mean < 16`, `trials > 64` binomial region to the
one-uniform inverse-CDF walk. The default `distcheck` covered that region
only through the 200k-draw unit moments test and a mean gate; the fixed
threshold CDF gates in `checkLongRun` used `Binomial(20, 0.3)` (the
per-trial path) and `CachedBinomial` inversion/HIN cases, not the
`Binomial` walk region.

## Change

- `checkBinomial` now draws 200k samples from `Binomial(1000, 0.012)`
  (mean 12, walk region) and gates:
  - empirical CDF at `k = 8`, `12`, and `16` against `Binomial.cdf`,
    each within `±0.006` (about 7 standard errors at 200k draws),
  - mean within `[11.9, 12.1]`,
  - variance within `[11.65, 12.05]` (exact 11.856).
- The gate runs in the default native and WASI distcheck, so a wrong walk
  PMF shape is caught without waiting for the 1e9-sample long run.
- No library code, stream, or benchmark changed; the milestone is
  test/gate-only.

## Validation

- `zig build distcheck --summary all` passes 5/5 steps and 2/2 tests with
  the new gate.
- `zig build validate-all --summary all` passes 124/124 steps and 1901/1901
  tests (native `alea-tests` 937/937, WASI Node tests 937/937), including
  both the native and WASI runs of the new walk gate.
