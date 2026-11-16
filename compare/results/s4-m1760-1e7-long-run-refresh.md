# S4-M1760 1e7 Long-Run Refresh After S4-M1758

Date: 2026-11-16

`zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
`distlongcheck ok (10000000 samples)`.

The run exercises the new scalar and vector wrapped skew-normal binned gates
alongside the full long gate set (discrete, cached-binomial,
huge-hypergeometric, negative-binomial mixture, beta-huge, continuous, tail,
and copula gates).

No library code changed in this milestone. The 1e9 evidence
(`compare/results/s4-m1757-1e9-long-run-refresh.md`) predates the new gates,
so this 1e7 run is the first long-run validation of the wrapped skew-normal.
