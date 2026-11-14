# S4-M1447 One-Uniform Inverse-CDF Walk in CachedBinomial

Date: 2026-11-14

## Gap

S4-M1444's `CachedBinomial` still used the exponential waiting-time race for
`mean < 16`, which draws about `mean + 1` exponentials per sample. The earlier
S4-M1412-era inverse-CDF probe measured a sequential walk about 35% faster but
was rejected because inlining it into `binomialFrom` cost `beta-binomial` and
`negative-binomial` through code layout. `CachedBinomial` is a separate type,
so the walk can live there without touching the shared path.

## Change

- `CachedBinomial`'s small-mean method is now an exact inverse-CDF walk.
  `init` precomputes `px0 = exp(n · log1p(−q))` and `ratio = q / (1 − q)`;
  each draw consumes one uniform and advances
  `px *= (n − k) / (k + 1) · ratio` until `u < px`.
- `log1p` keeps `q^n` accurate when `q` is tiny and `1 − q` would round to
  one.
- The stream contract is documented: the law matches `Binomial`; the per-draw
  stream matches wherever both use the same method (fair, packed dyadic,
  per-trial, and HIN), while the small-mean region uses the walk.
  `Binomial`/`binomialFrom` are untouched.

## Probe

8,000,000 draws per case, best of three runs, same `FastPrng` seed:

| `n` | `p` | mean | waiting (M/s) | inversion (M/s) | delta |
| --- | --- | --- | --- | --- | --- |
| 1000 | 0.001 | 1 | 75.3 | 108.8 | +44% |
| 1000 | 0.002 | 2 | 59.4 | 86.7 | +46% |
| 1000 | 0.004 | 4 | 48.3 | 69.6 | +44% |
| 1000 | 0.008 | 8 | 38.1 | 56.6 | +49% |
| 1000 | 0.012 | 12 | 32.2 | 48.6 | +51% |
| 1000 | 0.015 | 15 | 28.7 | 43.4 | +51% |
| 10000 | 0.0012 | 12 | 32.1 | 47.9 | +49% |
| 100 | 0.12 | 12 | 32.2 | 47.9 | +49% |

Benchmark rows (16Mi): `alea binomial runtime sampler mean-12` 34.2M
checksum `787393` -> `alea binomial runtime cached mean-12` 49.3M checksum
`787277` (+44%, exact stream shifted as documented). The mean-100 HIN pair
stays 17.1M/36.8M with identical checksum `6552418`.

## Validation

- New `cached binomial inversion region has plausible moments` test: 200,000
  draws for `(1000, 0.001)`, `(1000, 0.012)`, `(100, 0.12)`, and
  `(10000, 0.0012)`; every mean is within 0.06 and every variance within 0.25
  of the exact binomial moments.
- The stream-parity test now compares exact streams only in the shared
  regions and checks support plus fill/self-consistency in the inversion
  region.
- `zig build test --summary all` passes 908/908 tests, including native
  `alea-tests` 889/889.
- `distcheck`, `statcheck`, and the 10M long run
  (`distlongcheck ok (10000000 samples)`) pass.
- The full 16MiB benchmark suite adds the two mean-12 runtime rows and keeps
  every pre-existing checksum identical (452 -> 454 rows, zero diffs).
