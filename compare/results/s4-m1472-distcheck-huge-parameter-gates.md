# S4-M1472 Distcheck Gates for the Huge-Parameter Paths

Date: 2026-11-14

## Gap

The recent huge-parameter fixes (tiny-p binomial waiting, fair-to-HIN
dispatch, stable HIN acceptance, hypergeometric H2PE/inverse init, and the
gamma-Poisson negative-binomial mixture) were covered only by unit tests; the
aggregate `distcheck` still used moderate parameters.

## Change

- `checkBinomial` adds mean gates at `(1e18, 2e-17)` (mean 20),
  `(1e9, 0.5)` (mean 5e8), and `(1e18, 0.5)` (mean 5e17).
- `checkDiscrete` adds gates for `negativeBinomial(2^20, 0.5)` (mean
  1.048576e6), `hypergeometric(1e18, 1e17, 5e17)` (mean 5e16), and
  `hypergeometric(1e18, 5, 5e17)` (mean 2.5).
- Every gate runs in the native, WASI, and libc distcheck variants through
  `validate-all`.

## Validation

- `zig build distcheck` prints `distcheck ok`.
- `zig build test --summary all` passes 917/917 tests (native `alea-tests`
  898/898), and the 10M long run passes.
- No sampling code changed, so the benchmark checksums are unaffected.
