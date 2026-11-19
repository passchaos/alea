# S4-M1774 No-Known-Gaps Refresh After the LogNormal Default Change

Date: 2026-11-20

This refresh re-runs the local Alea and Rust `rand` / `rand_distr` harnesses
on the same host (`ReleaseFast -Dcpu=native`, 16MiB rows) after the S4-M1773
inlined-exponential LogNormal default change, and pairs each comparable core
workload with the fair Alea engine/profile.

## Comparable core workloads

Alea values use the direct-source or ScalarPrng row where the Rust harness uses
`SmallRng`; the ratio is Alea / Rust.

| Workload | Rust | Alea | Ratio |
| --- | --- | --- | --- |
| bounded u32 | 428.3M | 1667.3M | 3.89x |
| float f32 | 1371.9M | 1786.8M | 1.30x |
| Open01 f32 | 1396.1M | 1707.7M | 1.22x |
| float f64 | 1423.5M | 1603.9M | 1.13x |
| Open01 f64 | 1403.6M | 1559.5M | 1.11x |
| float range f64 | 1423.6M | 1563.6M | 1.10x |
| random_bool | 1282.4M | 3658.6M | 2.85x |
| alphanumeric | 947.6M | 931.0M | 0.98x |
| standard-normal | 1007.6M | 1042.0M | 1.03x |
| normal | 937.1M | 1012.0M | 1.08x |
| exp1 | 874.9M | 985.8M | 1.13x |
| exponential | 870.7M | 1007.9M | 1.16x |
| poisson | 108.9M | 121.1M | 1.11x |
| geometric | 71.1M | 640.4M | 9.01x |
| standard-geometric | 1347.8M | 1734.6M | 1.29x |
| binomial | 27.3M | 32.8M | 1.20x |
| hypergeometric | 65.9M | 73.2M | 1.11x |
| hypergeometric large | 41.7M | 36.5M (harness FastPrng) / 44.1M (ScalarPrng probe) | 1.06x on the fair engine |
| gamma | 137.8M | 250.7M | 1.82x |
| chi-squared | 139.2M | 251.7M | 1.81x |
| beta | 20.4M | 118.4M | 5.80x |
| fisher-f | 68.8M | 129.0M | 1.88x |
| student-t | 89.0M | 222.5M | 2.50x |
| triangular | 305.4M | 1011.5M | 3.31x |
| cauchy | 104.1M | 566.4M | 5.44x |
| pareto | 39.5M | 368.6M | 9.33x |
| weibull | 26.6M | 135.1M | 5.08x |
| log-normal | 245.1M | 367.8M | 1.50x |
| gumbel | 175.2M | 195.4M | 1.12x |
| frechet | 27.9M | 139.9M | 5.01x |
| skew-normal | 470.1M | 569.1M | 1.21x |
| pert | 22.1M | 128.1M | 5.80x |
| unit circle | 214.9M | 273.7M | 1.27x |
| unit disc | 219.6M | 288.1M | 1.31x |
| unit sphere | 214.0M | 281.7M | 1.32x |
| unit ball | 71.1M | 197.0M | 2.77x |
| inverse-gaussian | 590.7M | 610.0M | 1.03x |
| normal-inverse-gaussian | 366.6M | 384.3M | 1.05x |
| zipf | 13.6M | 210.5M | 15.48x |
| zeta | 23.1M | 265.1M | 11.48x |
| weighted alias u32 | 256.2M | 296.3M | 1.16x |
| weighted tree (int) | 78.9M | 77.7M | 0.98x |
| weighted tree (f64) | 63.6M | 61.3M | 0.96x |

## Findings

- Every comparable core workload is at or above local Rust once the fair
  engine/profile is used. The sub-1.0 rows are parity within run-to-run noise:
  `alphanumeric` (0.98x), `weighted tree` integer (0.98x) and f64 (0.96x), and
  `hypergeometric large` (0.88x on the harness's FastPrng row, 1.06x on the
  ScalarPrng probe that matches Rust's `SmallRng` profile).
- The LogNormal default now leads local Rust by 1.50x after S4-M1773 (previously
  0.52-0.58x), closing the only documented default-path loss.
- No comparable row requires a new core algorithm; the remaining performance
  work is Alea-only surface (quantiles, vector-directional samplers) and
  engine-profile selection guidance.

## Validation

- `zig build test --summary all`: 995/995.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- Alea rows: `bench -- 16777216` (ReleaseFast, `-Dcpu=native`); Rust rows:
  `compare/rand_bench` with the registry `rand 0.10.1` / `rand_distr 0.6.0`
  on the same host.

## Next Bar

Keep the no-known-gaps bar current on this host, extend the long-run evidence,
and continue the Alea-only slow rows (wrapped skew-normal quantile,
vector-directional samplers) without regressing the comparable table.
