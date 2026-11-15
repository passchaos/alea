# S4-M1598 Von Mises CDF Distcheck Gates

Date: 2026-11-15

## Change

Added two sampler-versus-CDF consistency gates for the new von Mises
diagnostics (`μ = 0.4`, `κ = 5`, threshold `x = −1`, analytic
`F = 0.002803677300247831`):

- default `distcheck` (native and WASI): 40k samples, tolerance
  `6·sqrt(p(1−p)/n) = 1.59e-3`;
- `--long` mode: the same gate with the standard-error-scaled tolerance at the
  requested sample count (`3.17e-5` at 1e8, `1.0e-5` at 1e9).

## Validation

- `zig build distcheck -Doptimize=ReleaseFast` passes (default gate on the
  native target; the WASI target runs the same gate in `validate-all`).
- `alea-distcheck --long 100000000` prints
  `distlongcheck ok (100000000 samples)` in 2:28 with the long gate passing.
- The gate ties the sampler's empirical distribution to the Fourier–Bessel
  CDF, so a convention error (cut, wrap, normalization) or a sampler/CDF
  mismatch would fail at the six-standard-error level.
- Tooling-only change: no library code, sampling stream, public API, or
  benchmark changed.

## Next

The next 1e9-sample refresh will exercise the same long gate at the full
1e9 bar alongside the S4-M1594 standard-error-scaled directional gates.
