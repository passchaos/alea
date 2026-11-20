# S4-M1841 Linear Lower-Tail Start for the Rice Quantile

Date: 2026-11-20

## Gap

The Rice quantile starts from a Wilson-Hilferty cube-root approximation of
the noncentral chi-square. That start is good in the body (4-12% relative
error) but poor in the lower tail: 29% at `p = 0.1` and 51% at `p = 0.01`,
which is where the Newton loop spends most of its iterations (4.47 on
average). Near zero the Rice density is linear in `x`, so the CDF inverts
in closed form there.

## Change

For `p < 0.2` the start is the exact inversion of the linear-density
approximation, `sigma·sqrt(2p·exp(nu²/(2·sigma²)))`; above that the
Wilson-Hilferty start is kept. A Newton-to-Halley upgrade was tried first
and rejected: the density derivative needs `besselI1Ratio`, whose cost
exceeds the 0.92 iterations it saves (the bench row fell 25%).

## Measurements

- Start error at `nu = sigma = 1`: `p = 0.01` 50.8% → 0.0%, `p = 0.1` 29.4%
  → 3.3%; the body keeps the Wilson-Hilferty errors.
- Direct `riceQuantile(p, 1, 1)` sweep: 196.3 ns → 169.1 ns per call (about
  −14%).
- Same-host A/B with two separately built `bench/throughput.zig` binaries
  (`ReleaseFast -Dcpu=native`, `-- 16777216`), four alternating pairs:
  `rice quantile` 6.068, 5.777, 5.357, 6.120 M/s before and 6.195, 5.670,
  6.518, 6.605 M/s after (median 5.923M to 6.357M, about +7%; three of four
  pairs).

## Accuracy

A round-trip audit over `nu ∈ {0, 0.5, 1, 5, 20}`, `sigma ∈ {0.5, 1, 2}`,
and `p` from 1e-6 to `1 − 1e-6` gives a worst relative error of 5.30e-11,
versus 7.74e-11 before — the start only changes the path, not the root.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The Rice quantile is now about 6.4M quantiles/s. The same lower-tail
linearisation may apply to the Hoyt quantile (Rayleigh start, 4.26
iterations); keep the no-known-gaps and long-run evidence current and
revisit the large-hypergeometric codegen gap.
