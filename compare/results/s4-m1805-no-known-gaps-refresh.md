# S4-M1805 No-Known-Gaps Refresh After the Quantile Wave

Date: 2026-11-20

## Scope

After the S4-M1788..M1804 work (Halley quantiles, Owen T tables, Marcum
bounds, direct-form densities), rerun the local Rust comparison in a single
window to confirm the no-known-gaps bar still holds. Same host,
`bench -- 16777216`, ReleaseFast `-Dcpu=native`, local `rand 0.10.1` /
`rand_distr 0.6.0` from the `/tmp/alea_rand_bench` harness.

## Results

Alea/Rust throughput ratio, sorted; the same-window absolute numbers are in
parentheses (M samples/s unless noted):

| Workload | Rust | Alea | Ratio |
| --- | --- | --- | --- |
| unit disc | 173.8 | 183.0 | 1.05x |
| unit circle | 167.0 | 182.5 | 1.09x |
| Poisson | 80.2 | 87.8 | 1.09x |
| unit sphere | 173.3 | 197.7 | 1.14x |
| hypergeometric skew-large | 31.6 | 36.3 | 1.15x |
| `StdRng` fill-only (MiB/s) | 2183.0 | 2528.0 | 1.16x |
| hypergeometric large | 29.1 | 35.1 | 1.21x |
| inverse-gaussian | 381.4 | 472.5 | 1.24x |
| normal-inverse-gaussian | 233.7 | 303.3 | 1.30x |
| `SmallRng` fill-only (MiB/s) | 8303.8 | 11194.0 | 1.35x |
| `SmallRng` next_u64 (M next/s) | 1055.9 | 1452.4 | 1.38x |
| exponential | 600.0 | 851.8 | 1.42x |
| normal | 653.4 | 946.7 | 1.45x |
| skew-normal | 300.7 | 452.6 | 1.51x |
| binomial | 21.3 | 32.6 | 1.53x |
| hypergeometric | 49.3 | 78.0 | 1.58x |
| skew-normal shape=2 | 256.0 | 414.4 | 1.62x |
| gumbel | 101.7 | 169.9 | 1.67x |
| unit ball | 55.9 | 126.1 | 2.26x |
| log-normal | 162.1 | 366.3 | 2.26x |
| student-t | 74.5 | 170.2 | 2.28x |
| gamma | 96.9 | 233.0 | 2.40x |
| `alea4x64` fill-only (MiB/s) | 8303.8 | 22091.8 | 2.66x |
| Fisher F | 48.3 | 135.4 | 2.80x |
| chi-squared | 97.4 | 290.1 | 2.98x |
| triangular | 257.8 | 1010.8 | 3.92x |
| Zipf | 9.1 | 56.9 | 6.25x |
| Frechet | 19.3 | 127.6 | 6.61x |
| PERT | 15.4 | 106.1 | 6.89x |
| Cauchy | 80.4 | 572.3 | 7.12x |
| Weibull | 18.0 | 130.8 | 7.27x |
| beta | 15.5 | 141.9 | 9.15x |
| geometric | 61.3 | 737.9 | 12.04x |
| Zeta | 16.2 | 195.3 | 12.06x |
| Pareto | 27.5 | 354.0 | 12.87x |

Every comparable workload is at or above the local Rust implementation in
this window, with the minimum at 1.05x (unit disc) and the engine fills at
1.16x (`StdRng`/ChaCha12) and 1.35x (`SmallRng`/xoshiro256++). The earlier
`chacha12 fill-only` deficit (0.90x in an older window) does not reproduce
in-window; the hidden-key prefix cost is unchanged, so this row should be
read as parity within host noise.

## Notes

- The host is shared and run-to-run variance is 5-15%; the ratios above come
  from one same-window pair of runs and should be re-measured before drawing
  conclusions about any single row.
- Alea-only surfaces (quantiles, vector-directional samplers) have no Rust
  counterpart and are tracked by their own evidence files.

## Next Bar

Keep this comparison current; the remaining Alea-only slow rows are the
wrapped skew-normal quantile (about 0.58M), skew-normal quantile (about
2.6M), and the extreme-shape `beta(0.1,0.1)` / `gamma(0.05,1)` /
`hoyt(q=0.01)` CDF-resolution limits noted in S4-M1797.
