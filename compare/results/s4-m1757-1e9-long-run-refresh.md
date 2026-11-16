# S4-M1757 1e9 Long-Run Refresh After the CDF Fast Paths

Date: 2026-11-16

`zig build -Doptimize=ReleaseFast distcheck -- --long 1000000000` prints
`distlongcheck ok (1000000000 samples)` and exits 0 (about 65 minutes).

The run validates the Owen T Gauss-Legendre fast path (S4-M1752) and the
Marcum P1 recurrence (S4-M1754) at the full 1e9 bar, including:

- the skew-normal and Rice continuous CDF gates,
- the scalar/vector wrapped normal binned gates,
- the merged-bin non-dyadic vector binomial gate and the dyadic
  geometric/binomial gates,
- the discrete, cached-binomial, huge-hypergeometric, negative-binomial
  mixture, beta-huge, continuous, tail, and copula gates.

No library code changed in this milestone; the CDF fast paths are
stream-preserving and the sampling gates are unchanged.
