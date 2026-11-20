# S4-M1853 No-Known-Gaps Refresh (Current Host)

Date: 2026-11-20

This refresh re-runs the local Alea and Rust `rand` / `rand_distr` harnesses
on the same host (`ReleaseFast -Dcpu=native`, 16MiB rows) after the
S4-M1833..M1852 changes. The sampler code is unchanged since the S4-M1832
refresh (this session's work touched CDF and quantile paths), so this run
re-validates the comparison on the current binary and catches any
regression from the shared helpers.

Each row was measured with the Rust harness interleaved in the same window
(two runs per side, best of the two). Absolute values are window-dependent,
so only the ratios should be compared across rows.

## Comparable core workloads

| Workload | Rust | Alea | Ratio |
| --- | --- | --- | --- |
| bounded u32 | 401.9M | 1683.3M | 4.19x |
| float f32 | 1223.1M | 1681.7M | 1.37x |
| Open01 f32 | 1187.2M | 1730.3M | 1.46x |
| OpenClosed01 f32 | 1225.8M | 1531.2M | 1.25x |
| float range f32 | 1251.3M | 1575.1M | 1.26x |
| float f64 | 1321.6M | 1608.5M | 1.22x |
| Open01 f64 | 1304.2M | 1570.2M | 1.20x |
| OpenClosed01 f64 | 1252.7M | 1563.6M | 1.25x |
| float range f64 | 1320.6M | 1586.9M | 1.20x |
| random_bool | 1244.4M | 3732.1M | 3.00x |
| alphanumeric | 1028.1M | 1045.3M | 1.02x |
| sample indices | 176.6M | 283.7M | 1.61x |
| standard-normal | 943.0M | 1023.3M | 1.09x |
| normal | 856.5M | 1032.6M | 1.21x |
| exp1 | 739.9M | 989.8M | 1.34x |
| exponential | 728.2M | 1002.9M | 1.38x |
| poisson (prebuilt) | 93.9M | 108.6M | 1.16x |
| geometric | 63.0M | 1531.5M | 24.3x |
| standard-geometric | 1220.1M | 2407.8M | 1.97x |
| binomial | 24.2M | 33.2M | 1.37x |
| hypergeometric | 57.0M | 78.1M | 1.37x |
| hypergeometric large | 37.4M | 35.4M | 0.95x |
| hypergeometric skew-large | 37.9M | 36.1M | 0.95x |
| gamma | 117.0M | 211.2M | 1.81x |
| chi-squared | 109.5M | 186.8M | 1.71x |
| beta | 16.2M | 150.5M | 9.29x |
| fisher-f | 52.8M | 150.2M | 2.84x |
| student-t | 72.3M | 240.7M | 3.33x |
| triangular | 253.6M | 997.7M | 3.93x |
| cauchy | 82.1M | 570.7M | 6.95x |
| pareto | 28.4M | 381.0M | 13.4x |
| weibull | 19.2M | 140.5M | 7.32x |
| log-normal | 223.8M | 334.9M | 1.50x |
| gumbel | 139.4M | 211.0M | 1.51x |
| frechet | 24.4M | 141.4M | 5.80x |
| skew-normal | 432.6M | 602.3M | 1.39x |
| skew-normal shape=2 | 391.1M | 542.8M | 1.39x |
| pert | 19.8M | 130.7M | 6.60x |
| unit circle | 192.1M | 264.7M | 1.38x |
| unit disc | 197.9M | 276.0M | 1.39x |
| unit sphere | 195.6M | 269.9M | 1.38x |
| unit ball | 64.6M | 190.6M | 2.95x |
| inverse-gaussian | 530.5M | 607.4M | 1.14x |
| normal-inverse-gaussian | 332.6M | 345.0M | 1.04x |
| zipf | 12.5M | 209.0M | 16.7x |
| zeta | 20.7M | 261.8M | 12.6x |
| weighted alias u32 | 215.5M | 302.4M | 1.40x |
| weighted tree update+sample | 66.5M | 81.6M | 1.23x |
| weighted tree f64 update+sample | 51.5M | 66.2M | 1.29x |

## Findings

- Every comparable core workload is at or above local Rust except the
  large-hypergeometric rows (`hypergeometric large` 0.95x, `skew-large`
  0.95x in this window; 0.86-0.87x in the busier S4-M1832 window). Both
  sides implement the same H2PE formulas; the remainder is codegen-level
  and every structural variant tried (cold-path extraction, branch hints,
  forced inlining, engine swaps, parameter hoisting) measured neutral or
  worse.
- The thinnest non-hypergeometric rows are `alphanumeric` (1.02x),
  `normal-inverse-gaussian` (1.04x), and `standard-normal` (1.09x).

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

Close the large-hypergeometric codegen gap (0.95x here, 0.86-0.87x in a
busy window) and keep the long-run evidence current.
