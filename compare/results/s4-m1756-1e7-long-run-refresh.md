# S4-M1756 1e7 Long-Run Refresh After the CDF Fast Paths

Date: 2026-11-16

`zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
`distlongcheck ok (10000000 samples)`.

The run validates the Owen T Gauss-Legendre fast path (S4-M1752) and the
Marcum P1 recurrence (S4-M1754) against the full long gate set, including the
skew-normal and Rice continuous CDF gates and the binned gates.

The 1e9 evidence (`compare/results/s4-m1751-1e9-long-run-refresh.md`) predates
these CDF fast paths; this 1e7 run confirms the new CDFs at the standard
long-run sample count. No library code changed in this milestone.
