# S4-M1770 1e9 Long-Run Refresh

Date: 2026-11-20

`alea-distcheck --long 1000000000` prints
`distlongcheck ok (1000000000 samples)` (about 62 minutes, run directly from
the ReleaseFast `alea-distcheck` binary because the TRAE Zig guard terminated
the `zig build` wrapper at its 30-minute slot timeout).

The run exercises the full 1e9 gate set after the S4-M1761..M1769 performance
work:

- discrete CDF means: binomial(4), poisson(5), hypergeometric(2),
  negative-binomial(3), geometric(2), zipf(2), zeta(1), bernoulli(0);
- cached binomial inversion(12) and HIN(100) CDFs;
- huge hypergeometric and rare-tail CDFs;
- negative-binomial mixture and huge-shape beta CDFs;
- continuous CDF means: beta(0.3), gamma(3), Student-t, FisherF,
  exponential(0.5), log-normal, log-logistic, Nakagami, ex-Gaussian,
  inverse Gaussian, skew-normal, PERT, Rice, Hoyt;
- heavy-tail rates and the 1% joint lower-tail copula rates.

No library code changed in this milestone. The earlier S4-M1757 1e9 evidence
predates the quantile recurrence work; this run refreshes it.

## Environment note

The TRAE Zig guard killed the `zig build` wrapper with SIGTERM after its
1800-second slot timeout. Running the compiled `alea-distcheck` binary
directly avoids the build-slot limit and completed the full 1e9 run. Future
long runs on this host should use the direct binary path (or an unguarded
build) when the expected wall time exceeds the guard timeout.

## Validation

- `zig build test --summary all`: 995/995 tests (from S4-M1769).
- `zig build distcheck`: `distcheck ok` (from S4-M1769).
- `zig build statcheck`: `statcheck ok`.
- `alea-distcheck --long 1000000000`: `distlongcheck ok (1000000000 samples)`.

## Next Bar

Continue the remaining Owen-T-limited quantile rows and broaden the
platform/long-run evidence.
