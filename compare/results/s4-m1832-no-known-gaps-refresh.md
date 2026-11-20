# S4-M1832 No-Known-Gaps Refresh (Current Host)

Date: 2026-11-20

This refresh re-runs the local Alea and Rust `rand` / `rand_distr` harnesses
on the same host (`ReleaseFast -Dcpu=native`, 16MiB rows) after the
S4-M1823..M1831 changes and pairs each comparable core workload with the
fair Alea row. Every row was measured with the Rust harness run interleaved
in the same window; the thin rows were repeated four to six times and are
reported as medians, the rest as the best of two interleaved runs. Absolute
values are window-dependent, so only the ratios should be compared across
rows.

Alea values use the ScalarPrng/direct row where the Rust harness uses
`SmallRng`, or the prebuilt-distribution row where Rust prebuilds the
distribution. The `alea poisson prebuilt scalar direct` row was added for
this refresh: the existing top-level row rebuilds the Ahrens-Dieter
parameters on every call, while Rust's row samples from a prebuilt
`Poisson`. The prebuilt row reaches 126.8M against Rust's 107.5M; the
per-call rebuild costs about a third of the throughput and is not the
workload the Rust row measures.

## Comparable core workloads

| Workload | Rust | Alea | Ratio |
| --- | --- | --- | --- |
| bounded u32 | 366.5M | 1432.2M | 3.91x |
| float f32 | 1181.4M | 1712.0M | 1.45x |
| Open01 f32 | 1282.6M | 1646.8M | 1.28x |
| OpenClosed01 f32 | 1293.2M | 1468.0M | 1.14x |
| float range f32 | 1341.5M | 1466.5M | 1.09x |
| float f64 | 1366.5M | 1577.2M | 1.15x |
| Open01 f64 | 1387.9M | 1543.0M | 1.11x |
| OpenClosed01 f64 | 1324.3M | 1511.6M | 1.14x |
| float range f64 | 1338.0M | 1484.7M | 1.11x |
| random_bool | 1263.1M | 3493.1M | 2.77x |
| alphanumeric | 1037.5M | 1070.3M | 1.03x |
| sample indices | 119.2M | 303.4M | 2.55x |
| standard-normal | 884.5M | 1105.1M | 1.25x |
| normal | 820.9M | 1071.8M | 1.31x |
| exp1 | 783.6M | 1111.8M | 1.42x |
| exponential | 787.0M | 1077.9M | 1.37x |
| poisson (prebuilt) | 107.5M | 126.8M | 1.18x |
| geometric | 67.0M | 1511.6M | 22.6x |
| standard-geometric | 1291.1M | 2420.7M | 1.87x |
| binomial | 24.2M | 34.0M | 1.40x |
| hypergeometric | 59.4M | 77.1M | 1.30x |
| hypergeometric large | 38.65M | 33.5M | 0.87x |
| hypergeometric skew-large | 40.3M | 34.65M | 0.86x |
| gamma | 108.2M | 213.6M | 1.97x |
| chi-squared | 118.3M | 210.2M | 1.78x |
| beta | 18.4M | 149.6M | 8.13x |
| fisher-f | 56.7M | 163.6M | 2.89x |
| student-t | 76.6M | 247.0M | 3.22x |
| triangular | 289.4M | 1030.7M | 3.56x |
| cauchy | 90.7M | 666.2M | 7.35x |
| pareto | 35.8M | 375.6M | 10.5x |
| weibull | 21.4M | 139.1M | 6.50x |
| log-normal | 217.6M | 402.2M | 1.85x |
| gumbel | 144.8M | 195.3M | 1.35x |
| frechet | 24.4M | 139.1M | 5.70x |
| skew-normal | 415.4M | 675.0M | 1.62x |
| skew-normal shape=2 | 377.6M | 625.1M | 1.66x |
| pert | 19.6M | 132.7M | 6.77x |
| unit circle | 198.1M | 273.8M | 1.38x |
| unit disc | 198.2M | 286.6M | 1.45x |
| unit sphere | 194.6M | 272.7M | 1.40x |
| unit ball | 64.2M | 183.9M | 2.86x |
| inverse-gaussian | 557.3M | 588.2M | 1.06x |
| normal-inverse-gaussian | 324.5M | 378.7M | 1.17x |
| zipf | 12.4M | 204.0M | 16.5x |
| zeta | 21.5M | 251.1M | 11.7x |
| weighted alias u32 | 244.4M | 298.9M | 1.22x |
| weighted tree update+sample | 75.2M | 81.6M | 1.09x |
| weighted tree f64 update+sample | 60.4M | 63.1M | 1.04x |

## Findings

- Every comparable core workload is at or above local Rust except the large
  hypergeometric rows: `hypergeometric large` (5000, 2500, 500) runs at
  0.87x and `hypergeometric skew-large` (10000, 1000, 2000) at 0.86x over
  six and four interleaved pairs respectively. Both sides implement the
  same H2PE algorithm with the same formulas (the Zig source mirrors the
  rand_distr source line for line), so the remaining difference is
  codegen-level; it is recorded as the next bar rather than a known
  algorithmic gap. The earlier S4-M1774 reading of 1.06x for this row was
  taken in a window where the Rust harness measured 34M instead of the
  current 38-41M.
- The thinnest non-hypergeometric rows are `alphanumeric` (1.03x),
  `weighted tree f64 update+sample` (1.04x), and `inverse-gaussian`
  (1.06x); all are parity-plus within run-to-run spread.
- The Poisson pairing needed a new bench row: the top-level free function
  rebuilds the Ahrens-Dieter parameters per call (about 81M/s), while the
  prebuilt distribution samples at 126.8M/s, which is the workload the Rust
  harness measures.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

Close the large-hypergeometric codegen gap (0.86-0.87x) and keep the
long-run evidence current.
